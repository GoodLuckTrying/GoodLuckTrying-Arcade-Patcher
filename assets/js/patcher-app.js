import { crc32Hex, toUint8Array } from "./crc32.js";
import { applyBps } from "./bps.js";
import { resolveAssetUrl } from "./repo-path.js";

const $ = (sel) => document.querySelector(sel);

export function isDirectFbNeoSupported(hackId, build) {
  if (!build || typeof build !== "object") return false;

  const sourceRomset = String(build.sourceRomset || "").toLowerCase();
  const outputZip = String(build.outputZip || "").toLowerCase();

  switch (hackId) {
    case "ghouls-artoria-v10":
      return true;
    case "gng-artoria-v12":
      if (sourceRomset !== "gng" && sourceRomset !== "makaimur") return false;
      if (outputZip.includes("enh")) return false;
      return outputZip.includes("maiden") || outputZip.includes("knight");
    case "gng-enhanced-v10":
      return sourceRomset === "gng" || sourceRomset === "makaimur";
    default:
      return false;
  }
}

export function getCompatibilityTags(hackId, build) {
  const tags = [{ label: "HBMame / Mame2003-plus", className: "support-tag indirect" }];
  if (isDirectFbNeoSupported(hackId, build)) {
    tags.push({ label: "Supported by FB Neo", className: "support-tag direct" });
  }
  return tags;
}

export function indexRomFiles(fileMap) {
  const index = new Map();
  for (const [path, data] of Object.entries(fileMap)) {
    const name = path.split(/[/\\]/).pop();
    if (name) index.set(name.toLowerCase(), { name, data });
  }
  return index;
}

/** Verify uploaded romset against manifest romset definition. */
export function verifyRomset(romIndex, romsetDef) {
  const results = [];
  let passed = 0;
  let failed = 0;
  let missing = 0;

  for (const [filename, expectedCrc] of Object.entries(romsetDef.roms)) {
    const key = filename.toLowerCase();
    const entry = romIndex.get(key);
    if (!entry) {
      results.push({ filename, status: "missing", expected: expectedCrc });
      missing++;
      continue;
    }
    const actual = crc32Hex(entry.data);
    if (actual === expectedCrc.toLowerCase()) {
      results.push({ filename, status: "pass", expected: expectedCrc, actual });
      passed++;
    } else {
      results.push({ filename, status: "fail", expected: expectedCrc, actual });
      failed++;
    }
  }

  return {
    ok: failed === 0 && missing === 0,
    passed,
    failed,
    missing,
    total: passed + failed + missing,
    results,
  };
}

/** Detect which manifest romset matches the uploaded zip. */
export function detectRomset(romIndex, manifest) {
  const matches = [];
  for (const [id, def] of Object.entries(manifest.romsets)) {
    const v = verifyRomset(romIndex, def);
    if (v.ok) matches.push({ id, label: def.label, verify: v });
  }
  return matches;
}

/** Builds available for a detected source romset id. */
export function buildsForRomset(manifest, romsetId) {
  return Object.entries(manifest.builds)
    .filter(([, cfg]) => cfg.sourceRomset === romsetId)
    .map(([id, cfg]) => ({ id, label: cfg.label, outputZip: cfg.outputZip, ...cfg }));
}

/** Optional note when zip filename doesn't match detected ROM layout. */
function zipFilenameHint(uploadName, detectedId) {
  const stem = uploadName.replace(/\.zip$/i, "").toLowerCase();
  if (stem === detectedId) return "";

  if (stem === "gng" && detectedId === "gngb") {
    return " Your gng.zip contains World set 3 ROMs (gg3/gg4/gg5 layout), not set 1 (mm_c_03/mm_c_04/mm_c_05).";
  }
  if (stem === "gng" && detectedId === "gnga") {
    return " Your gng.zip contains World set 2 ROMs, not set 1.";
  }
  if (stem === "gng" && detectedId === "gngc") {
    return " Your gng.zip contains World set 4 ROMs, not set 1.";
  }
  if (stem !== detectedId) {
    return ` Zip is named ${stem}.zip but ROM checksums match the ${detectedId} set.`;
  }
  return "";
}

function renderVerifyTable(container, verify) {
  container.innerHTML = "";
  const table = document.createElement("table");
  table.className = "verify-table";
  table.innerHTML = "<thead><tr><th>File</th><th>Status</th><th>CRC32</th></tr></thead>";
  const tbody = document.createElement("tbody");
  for (const row of verify.results) {
    const tr = document.createElement("tr");
    tr.className = `row-${row.status}`;
    const crcCell =
      row.status === "pass"
        ? row.actual
        : row.status === "fail"
          ? `expected ${row.expected}, got ${row.actual}`
          : "—";
    tr.innerHTML = `<td>${row.filename}</td><td>${row.status.toUpperCase()}</td><td><code>${crcCell}</code></td>`;
    tbody.appendChild(tr);
  }
  table.appendChild(tbody);
  container.appendChild(table);

  const summary = document.createElement("p");
  summary.className = verify.ok ? "msg-ok" : "msg-err";
  summary.textContent = verify.ok
    ? `All ${verify.total} ROM checksums match.`
    : `${verify.passed} passed, ${verify.failed} failed, ${verify.missing} missing (of ${verify.total}).`;
  container.appendChild(summary);
}

async function fetchPatch(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Failed to fetch patch: ${url}`);
  return new Uint8Array(await res.arrayBuffer());
}

/** Apply one build; returns { files: {outputName: Uint8Array}, log: [] } */
export async function applyBuild(romIndex, build, onProgress) {
  const log = [];
  const outFiles = {};

  for (const entry of build.layout) {
    const srcKey = entry.source.toLowerCase();
    const srcEntry = romIndex.get(srcKey);
    if (!srcEntry) {
      log.push({ type: "skip", file: entry.source, message: "source not found" });
      continue;
    }

    if (!entry.patch) {
      outFiles[entry.output] = srcEntry.data;
      log.push({ type: "copy", file: entry.source, out: entry.output });
      onProgress?.(`Copied ${entry.source}`);
      continue;
    }

    const patchUrl = resolveAssetUrl(build.patchesBase, entry.patch);
    onProgress?.(`Fetching patch for ${entry.source}…`);
    const patchBytes = await fetchPatch(patchUrl);
    onProgress?.(`Patching ${entry.source}…`);
    const result = applyBps(srcEntry.data, patchBytes);
    outFiles[entry.output] = result.output;
    log.push({
      type: "patch",
      file: entry.source,
      patch: entry.patch,
      out: entry.output,
      crcOk: result.crcOk,
    });
    onProgress?.(`Patched ${entry.source} → ${entry.output}  ${result.crcOk ? "CRC OK" : "CRC WRONG"}`);
  }

  return { files: outFiles, log };
}

export async function createZipFromFiles(files) {
  const zip = new JSZip();
  for (const [name, data] of Object.entries(files)) {
    zip.file(name, data);
  }
  return zip.generateAsync({ type: "blob", compression: "DEFLATE" });
}

export async function extractZip(file) {
  const zip = await JSZip.loadAsync(await file.arrayBuffer());
  const map = {};
  const tasks = [];
  zip.forEach((relPath, zipEntry) => {
    if (zipEntry.dir) return;
    tasks.push(
      zipEntry.async("uint8array").then((data) => {
        map[relPath] = data;
      })
    );
  });
  await Promise.all(tasks);
  return map;
}

export function initPatcherPage(manifest) {
  const fileInput = $("#rom-zip");
  const verifySection = $("#verify-section");
  const verifyResults = $("#verify-results");
  const buildSection = $("#build-section");
  const buildList = $("#build-list");
  const patchBtn = $("#patch-btn");
  const logEl = $("#patch-log");
  const statusEl = $("#status");

  let romIndex = null;
  let detectedRomset = null;
  let selectedBuildId = null;

  fileInput.addEventListener("change", async () => {
    buildSection.hidden = true;
    verifySection.hidden = true;
    romIndex = null;
    detectedRomset = null;
    selectedBuildId = null;
    patchBtn.disabled = true;

    const file = fileInput.files?.[0];
    if (!file) return;

    statusEl.textContent = "Reading zip…";
    try {
      const fileMap = await extractZip(file);
      romIndex = indexRomFiles(fileMap);
      const matches = detectRomset(romIndex, manifest);

      verifySection.hidden = false;

      if (matches.length === 0) {
        // Show best-effort verify against all romsets
        verifyResults.innerHTML = "<p class=\"msg-err\">No matching base romset found. Checksums did not match any supported set.</p>";
        const firstId = Object.keys(manifest.romsets)[0];
        if (firstId) {
          const sample = verifyRomset(romIndex, manifest.romsets[firstId]);
          renderVerifyTable(verifyResults, sample);
        }
        statusEl.textContent = "Verification failed.";
        return;
      }

      detectedRomset = matches[0];
      renderVerifyTable(verifyResults, detectedRomset.verify);
      const hint = zipFilenameHint(file.name, detectedRomset.id);
      statusEl.textContent = `Detected: ${detectedRomset.label}.${hint}`;

      const builds = buildsForRomset(manifest, detectedRomset.id);
      buildList.innerHTML = "";

      const compatibilityNote = document.createElement("p");
      compatibilityNote.className = "compatibility-note";
      compatibilityNote.textContent = "All hacks are supported by HBMame / Mame2003-plus. Patches marked Supported by FB Neo are directly supported in FB Neo.";
      buildList.appendChild(compatibilityNote);

      for (const b of builds) {
        const label = document.createElement("label");
        label.className = "build-option";
        const radio = document.createElement("input");
        radio.type = "radio";
        radio.name = "build";
        radio.value = b.id;
        radio.addEventListener("change", () => {
          selectedBuildId = b.id;
          patchBtn.disabled = false;
        });
        label.appendChild(radio);

        const text = document.createElement("span");
        text.textContent = ` ${b.label} (${b.outputZip})`;
        label.appendChild(text);

        const tags = getCompatibilityTags(manifest.id, b);
        for (const tagInfo of tags) {
          const tag = document.createElement("span");
          tag.className = tagInfo.className;
          tag.textContent = tagInfo.label;
          label.appendChild(tag);
        }

        buildList.appendChild(label);
      }
      buildSection.hidden = false;
      if (builds.length === 1) {
        buildList.querySelector("input").checked = true;
        selectedBuildId = builds[0].id;
        patchBtn.disabled = false;
      }
    } catch (err) {
      statusEl.textContent = `Error: ${err.message}`;
      console.error(err);
    }
  });

  patchBtn.addEventListener("click", async () => {
    if (!romIndex || !selectedBuildId) return;
    const build = manifest.builds[selectedBuildId];
    patchBtn.disabled = true;
    logEl.textContent = "";
    statusEl.textContent = "Patching…";

    try {
      const { files, log } = await applyBuild(romIndex, build, (msg) => {
        logEl.textContent += msg + "\n";
        logEl.scrollTop = logEl.scrollHeight;
      });

      const errors = log.filter((l) => l.type === "patch" && l.crcOk === false);
      if (errors.length) {
        statusEl.textContent = `Done with ${errors.length} CRC warning(s).`;
      } else {
        statusEl.textContent = "Patch complete. Download starting…";
      }

      const blob = await createZipFromFiles(files);
      if (typeof window.gtag === "function") {
        window.gtag("event", "patch_download", {
          hack_id: manifest.id,
          hack_title: manifest.title,
          build_id: build.id,
          build_label: build.label,
          romset_id: detectedRomset?.id,
          romset_label: detectedRomset?.label,
          output_zip: build.outputZip,
        });
      }
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = build.outputZip;
      a.click();
      URL.revokeObjectURL(a.href);
    } catch (err) {
      statusEl.textContent = `Patch failed: ${err.message}`;
      console.error(err);
    } finally {
      patchBtn.disabled = false;
    }
  });
}

export async function loadManifest(id) {
  const res = await fetch(resolveAssetUrl("manifests", `${id}.json`));
  if (!res.ok) throw new Error(`Manifest not found: ${id}`);
  return res.json();
}
