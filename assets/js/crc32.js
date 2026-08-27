/** Standard CRC-32 (IEEE / ZIP / Ethernet polynomial). */
export function crc32(bytes) {
  let crc = 0xffffffff;
  for (let i = 0; i < bytes.length; i++) {
    crc ^= bytes[i];
    for (let j = 0; j < 8; j++) {
      crc = (crc >>> 1) ^ (crc & 1 ? 0xedb88320 : 0);
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

export function crc32Hex(bytes) {
  return crc32(bytes).toString(16).padStart(8, "0");
}

/** Read bytes from File/Blob/ArrayBuffer/Uint8Array. */
export async function toUint8Array(input) {
  if (input instanceof Uint8Array) return input;
  if (input instanceof ArrayBuffer) return new Uint8Array(input);
  if (input?.arrayBuffer) return new Uint8Array(await input.arrayBuffer());
  throw new TypeError("Unsupported input type");
}
