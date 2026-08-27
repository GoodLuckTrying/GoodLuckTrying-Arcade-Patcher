import { resolveAssetUrl, isFileProtocol } from "./repo-path.js";

/** Fisher–Yates shuffle (returns new array). */
export function shuffle(files) {
  const a = [...files];
  for (let i = 0; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function isGifFile(name) {
  return name.toLowerCase().endsWith(".gif");
}

/** Delay as browsers play it; byte-swapped metadata is clamped to ~20ms/frame. */
function browserPlaybackDelayCs(block) {
  if (block.length < 4) return 10;
  const le = block[2] | (block[3] << 8);
  const be = (block[2] << 8) | block[3];
  if (le > 500 && (le & 0xff) === 0 && be > 0 && be <= 600) return 2;
  return le || 10;
}

/**
 * Sum frame delays for one GIF loop (centiseconds → ms).
 * Falls back to 2000ms if parsing fails.
 */
export function parseGifLoopDurationMs(bytes) {
  if (bytes.length < 13) return 2000;
  if (String.fromCharCode(bytes[0], bytes[1], bytes[2]) !== "GIF") return 2000;

  let pos = 6;
  const lsdPacked = bytes[pos + 4];
  pos += 7;

  if (lsdPacked & 0x80) {
    const gctSize = 2 << (lsdPacked & 0x07);
    pos += gctSize * 3;
  }

  let totalCs = 0;
  let pendingDelayCs = 10;
  let frameCount = 0;

  const skipSubBlocks = () => {
    while (pos < bytes.length && bytes[pos] !== 0) {
      pos += bytes[pos] + 1;
    }
    if (pos < bytes.length) pos++;
  };

  while (pos < bytes.length) {
    const introducer = bytes[pos++];
    if (introducer === 0x3b) break;

    if (introducer === 0x21) {
      const label = bytes[pos++];
      if (label === 0xf9) {
        const blockSize = bytes[pos++];
        const block = bytes.subarray(pos, pos + blockSize);
        pendingDelayCs = browserPlaybackDelayCs(block);
        pos += blockSize;
        skipSubBlocks();
      } else {
        if (label === 0xff) {
          const blockSize = bytes[pos++];
          pos += blockSize;
        }
        skipSubBlocks();
      }
    } else if (introducer === 0x2c) {
      frameCount++;
      totalCs += pendingDelayCs;
      pendingDelayCs = 10;
      const localPacked = bytes[pos + 8];
      pos += 9;
      if (localPacked & 0x80) {
        const lctSize = 2 << (localPacked & 0x07);
        pos += lctSize * 3;
      }
      pos++;
      skipSubBlocks();
    }
  }

  let ms = totalCs * 10;
  if (ms <= 0 && frameCount > 0) ms = frameCount * 100;
  if (ms <= 0) return 2000;
  return Math.max(ms, 400);
}

const FETCH_TIMEOUT_MS = 30000;
const FADE_MS = 450;

async function fetchBytes(url) {
  const res = await fetch(url, { signal: AbortSignal.timeout(FETCH_TIMEOUT_MS) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return new Uint8Array(await res.arrayBuffer());
}

/** Load image after src change; do not trust stale img.complete. */
function waitForImage(img, timeoutMs = 8000) {
  return new Promise((resolve) => {
    let done = false;
    const finish = (ok) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      img.onload = null;
      img.onerror = null;
      resolve(ok);
    };
    const timer = setTimeout(() => finish(img.naturalWidth > 0), timeoutMs);
    img.onload = () => finish(true);
    img.onerror = () => finish(false);
  });
}

async function assignImageSrc(img, src) {
  const loadPromise = waitForImage(img);
  img.src = src;
  await loadPromise;
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Shuffled preview slideshow. PNG/JPG: `stillMs` each. GIF: one loop then next.
 */
export function initPreviewSlideshow(container, manifest, stillMs = 1000) {
  const pool = manifest?.previews ?? [];
  if (!pool.length || !manifest?.previewsFolder) {
    container.hidden = true;
    return null;
  }

  container.hidden = false;
  container.classList.add("preview-slideshow");
  container.innerHTML = "";

  const layers = [0, 1].map(() => {
    const img = document.createElement("img");
    img.className = "preview-slide";
    img.alt = `${manifest.title} preview`;
    img.decoding = "async";
    container.appendChild(img);
    return img;
  });

  let queue = shuffle(pool);
  let idx = 0;
  let timer = null;
  let cancelled = false;
  let busy = false;
  let activeLayer = 0;
  let layerObjectUrls = [null, null];
  let pending = null;
  let preloadPromise = null;

  const revokeLayerUrl = (layerIdx) => {
    if (layerObjectUrls[layerIdx]) {
      URL.revokeObjectURL(layerObjectUrls[layerIdx]);
      layerObjectUrls[layerIdx] = null;
    }
  };

  const nextFile = () => {
    if (idx >= queue.length) {
      queue = shuffle(pool);
      idx = 0;
    }
    return queue[idx++];
  };

  const peekNextFile = () => {
    let peekIdx = idx;
    let peekQueue = queue;
    if (peekIdx >= peekQueue.length) {
      peekQueue = shuffle(pool);
      peekIdx = 0;
    }
    return peekQueue[peekIdx];
  };

  const schedule = (ms) => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      if (!cancelled) showNext();
    }, ms);
  };

  async function loadSlide(file) {
    const url = resolveAssetUrl(manifest.previewsFolder, file);

    if (isGifFile(file)) {
      try {
        const bytes = await fetchBytes(url);
        return {
          src: URL.createObjectURL(new Blob([bytes], { type: "image/gif" })),
          delayMs: parseGifLoopDurationMs(bytes),
          objectUrl: true,
        };
      } catch (err) {
        console.error("GIF preview failed:", url, err);
        return {
          src: `${url}${url.includes("?") ? "&" : "?"}t=${Date.now()}`,
          delayMs: 2000,
          objectUrl: false,
        };
      }
    }

    return {
      src: `${url}${url.includes("?") ? "&" : "?"}t=${Date.now()}`,
      delayMs: stillMs,
      objectUrl: false,
    };
  }

  async function loadIntoLayer(layerIdx, file) {
    const slide = await loadSlide(file);
    await assignImageSrc(layers[layerIdx], slide.src);
    revokeLayerUrl(layerIdx);
    if (slide.objectUrl) layerObjectUrls[layerIdx] = slide.src;
    return slide.delayMs;
  }

  async function crossfadeTo(layerIdx) {
    if (layerIdx === activeLayer) return;

    const prevLayer = activeLayer;
    layers[layerIdx].classList.add("is-active");
    layers[prevLayer].classList.remove("is-active");
    await wait(FADE_MS);

    layers[prevLayer].removeAttribute("src");
    revokeLayerUrl(prevLayer);
    activeLayer = layerIdx;
  }

  async function preloadUpcoming() {
    if (cancelled) return;

    const layerIdx = 1 - activeLayer;
    const file = peekNextFile();
    const slide = await loadSlide(file);

    if (cancelled) {
      if (slide.objectUrl) URL.revokeObjectURL(slide.src);
      return;
    }

    await assignImageSrc(layers[layerIdx], slide.src);
    revokeLayerUrl(layerIdx);
    if (slide.objectUrl) layerObjectUrls[layerIdx] = slide.src;

    pending = { layerIdx, delayMs: slide.delayMs };
  }

  function queuePreload() {
    if (preloadPromise || cancelled) return;
    preloadPromise = preloadUpcoming()
      .catch((err) => {
        console.warn("Preview preload failed:", err);
        pending = null;
      })
      .finally(() => {
        preloadPromise = null;
      });
  }

  const showNext = async () => {
    if (cancelled) return;
    if (busy) {
      schedule(50);
      return;
    }
    busy = true;

    try {
      if (preloadPromise) {
        await preloadPromise.catch(() => {});
      }

      const targetLayer = 1 - activeLayer;

      if (pending?.layerIdx === targetLayer) {
        const { delayMs } = pending;
        pending = null;
        await crossfadeTo(targetLayer);
        nextFile();
        if (!cancelled) {
          schedule(delayMs);
          queuePreload();
        }
      } else {
        pending = null;
        const file = nextFile();
        const delayMs = await loadIntoLayer(targetLayer, file);
        await crossfadeTo(targetLayer);
        if (!cancelled) {
          schedule(delayMs);
          queuePreload();
        }
      }
    } finally {
      busy = false;
    }
  };

  (async () => {
    busy = true;
    try {
      const file = nextFile();
      const delayMs = await loadIntoLayer(0, file);
      layers[0].classList.add("is-active");
      activeLayer = 0;
      if (!cancelled) {
        schedule(delayMs);
        queuePreload();
      }
    } finally {
      busy = false;
    }
  })();

  return () => {
    cancelled = true;
    if (timer) clearTimeout(timer);
    for (let i = 0; i < layers.length; i++) {
      layers[i].classList.remove("is-active");
      layers[i].removeAttribute("src");
      revokeLayerUrl(i);
    }
    pending = null;
  };
}

export async function loadManifest(id) {
  if (window.HACKS_DATA?.[id] && isFileProtocol()) {
    const res = await fetch(resolveAssetUrl("manifests", `${id}.json`)).catch(() => null);
    if (res?.ok) return res.json();
    throw new Error(
      "Patcher requires a local web server on file:// pages. Run serve.bat or: python -m http.server 8080"
    );
  }
  const res = await fetch(resolveAssetUrl("manifests", `${id}.json`));
  if (!res.ok) throw new Error(`Manifest not found: ${id}`);
  return res.json();
}

function previewManifestFor(id) {
  return window.HACKS_DATA?.[id] ?? window.WIP_HACKS_DATA?.[id] ?? null;
}

export async function initAllPreviewSlideshows(stillMs = 1000) {
  const nodes = document.querySelectorAll("[data-preview-hack]");
  const cleanups = [];

  for (const node of nodes) {
    const hackId = node.getAttribute("data-preview-hack");
    if (!hackId) continue;
    try {
      let manifest = previewManifestFor(hackId);
      if (!manifest) {
        manifest = await loadManifest(hackId);
      }
      const stop = initPreviewSlideshow(node, manifest, stillMs);
      if (stop) cleanups.push(stop);
    } catch (err) {
      console.warn(`Preview load failed for ${hackId}:`, err);
      node.hidden = true;
    }
  }

  return () => cleanups.forEach((fn) => fn());
}
