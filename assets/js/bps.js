import { crc32 } from "./crc32.js";

/** Beat/Flips variable-length integer (MSB set = last byte). */
function readVlv(data, state) {
  let result = 0;
  let shift = 1;
  while (true) {
    if (state.offset >= data.length) {
      throw new Error("Unexpected end of BPS patch");
    }
    const byte = data[state.offset++];
    result += (byte & 0x7f) * shift;
    if (byte & 0x80) break;
    shift <<= 7;
    result += shift;
  }
  return result;
}

/** Signed relative offset for SourceCopy / TargetCopy. */
function readSignedOffset(data, state) {
  const value = readVlv(data, state);
  const magnitude = value >> 1;
  return value & 1 ? -magnitude : magnitude;
}

function readU32LE(data, offset) {
  return (
    data[offset] |
    (data[offset + 1] << 8) |
    (data[offset + 2] << 16) |
    (data[offset + 3] << 24)
  ) >>> 0;
}

/** Apply a BPS1 patch to source ROM bytes. Returns patched output. */
export function applyBps(source, patchBytes) {
  const patch = patchBytes instanceof Uint8Array ? patchBytes : new Uint8Array(patchBytes);
  if (patch.length < 19) throw new Error("Patch file too small");
  if (String.fromCharCode(patch[0], patch[1], patch[2], patch[3]) !== "BPS1") {
    throw new Error("Not a BPS1 patch");
  }

  const state = { offset: 4 };
  const sourceSize = readVlv(patch, state);
  const targetSize = readVlv(patch, state);
  const metaLen = readVlv(patch, state);
  if (state.offset + metaLen > patch.length - 12) {
    throw new Error("Invalid BPS metadata length");
  }
  state.offset += metaLen;

  if (source.length !== sourceSize) {
    throw new Error(`Source size mismatch: expected ${sourceSize}, got ${source.length}`);
  }

  const output = new Uint8Array(targetSize);
  let outPos = 0;
  let sourceRel = 0;
  let targetRel = 0;
  const footerStart = patch.length - 12;

  while (state.offset < footerStart) {
    const encoded = readVlv(patch, state);
    const command = encoded & 3;
    const length = (encoded >> 2) + 1;

    if (outPos + length > targetSize) {
      throw new Error("Patch would write past end of output");
    }

    switch (command) {
      case 0: // SourceRead
        output.set(source.subarray(outPos, outPos + length), outPos);
        outPos += length;
        break;
      case 1: // TargetRead
        if (state.offset + length > footerStart) throw new Error("TargetRead past patch data");
        output.set(patch.subarray(state.offset, state.offset + length), outPos);
        state.offset += length;
        outPos += length;
        break;
      case 2: {
        // SourceCopy
        const srcDelta = readSignedOffset(patch, state);
        sourceRel += srcDelta;
        if (sourceRel < 0) throw new Error("SourceCopy out of range");
        for (let i = 0; i < length; i++) {
          if (sourceRel >= source.length) throw new Error("SourceCopy out of range");
          output[outPos++] = source[sourceRel++];
        }
        break;
      }
      case 3: {
        // TargetCopy — reads may use bytes written earlier in this command
        const tgtDelta = readSignedOffset(patch, state);
        targetRel += tgtDelta;
        if (targetRel < 0) throw new Error("TargetCopy out of range");
        for (let i = 0; i < length; i++) {
          if (targetRel < 0 || targetRel >= outPos) throw new Error("TargetCopy out of range");
          output[outPos++] = output[targetRel++];
        }
        break;
      }
      default:
        throw new Error(`Unknown BPS command ${command}`);
    }
  }

  if (outPos !== targetSize) {
    throw new Error(`Patch output size mismatch: wrote ${outPos}, expected ${targetSize}`);
  }

  const expectedSourceCrc = readU32LE(patch, footerStart);
  const expectedTargetCrc = readU32LE(patch, footerStart + 4);
  const actualSourceCrc = crc32(source);
  const actualTargetCrc = crc32(output);

  const sourceOk = actualSourceCrc === expectedSourceCrc;
  const targetOk = actualTargetCrc === expectedTargetCrc;

  return {
    output,
    sourceOk,
    targetOk,
    crcOk: sourceOk && targetOk,
  };
}

/** Read source/target CRC from BPS footer without applying. */
export function readBpsCrcs(patchBytes) {
  const patch = patchBytes instanceof Uint8Array ? patchBytes : new Uint8Array(patchBytes);
  if (patch.length < 16) return null;
  if (String.fromCharCode(patch[0], patch[1], patch[2], patch[3]) !== "BPS1") return null;
  const footerStart = patch.length - 12;
  return {
    source: readU32LE(patch, footerStart),
    target: readU32LE(patch, footerStart + 4),
  };
}
