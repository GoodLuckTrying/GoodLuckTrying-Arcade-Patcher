import { assetUrl } from "./repo-path.js";
import { initPreviewSlideshow } from "./preview-slideshow.js";

function releaseZipLabel(downloadUrl) {
  const filename = downloadUrl.split("/").pop() ?? downloadUrl;
  return `Download ${filename}`;
}

function previewManifestFor(id) {
  return (
    window.HACKS_DATA?.[id] ??
    window.WIP_HACKS_DATA?.[id] ??
    window.OTHER_HACKS?.find((hack) => hack.id === id) ??
    null
  );
}

function openPreviewModal(manifest) {
  if (!manifest?.previews?.length || !manifest?.previewsFolder) return;

  let modal = document.getElementById("preview-modal");
  if (!modal) {
    modal = document.createElement("div");
    modal.id = "preview-modal";
    modal.className = "preview-modal";
    modal.innerHTML = `
      <div class="preview-modal__backdrop" data-close-preview-modal="true"></div>
      <div class="preview-modal__dialog" role="dialog" aria-modal="true" aria-label="Hack previews">
        <button type="button" class="preview-modal__close" aria-label="Close previews">×</button>
        <div class="preview-modal__content"></div>
      </div>
    `;
    document.body.appendChild(modal);

    modal.addEventListener("click", (event) => {
      const closeTarget = event.target.closest("[data-close-preview-modal]");
      if (closeTarget) {
        modal.classList.remove("is-open");
        return;
      }
      if (event.target === modal) {
        modal.classList.remove("is-open");
      }
    });

    modal.querySelector(".preview-modal__close")?.addEventListener("click", () => {
      modal.classList.remove("is-open");
    });

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && modal.classList.contains("is-open")) {
        modal.classList.remove("is-open");
      }
    });
  }

  const content = modal.querySelector(".preview-modal__content");
  const title = document.createElement("h2");
  title.textContent = manifest.title;
  content.replaceChildren(title);

  const slideshow = document.createElement("div");
  slideshow.className = "preview-slideshow preview-modal__slideshow";
  content.appendChild(slideshow);

  const stop = initPreviewSlideshow(slideshow, manifest, 1200);
  modal.dataset.previewStop = String(stop);
  modal.classList.add("is-open");

  const previousStop = modal._previewStop;
  if (typeof previousStop === "function") previousStop();
  modal._previewStop = stop;
}

if (!document.body.dataset.previewLinksBound) {
  document.addEventListener("click", (event) => {
    const link = event.target.closest("a[data-preview-hack]");
    if (!link) return;
    event.preventDefault();
    const manifest = previewManifestFor(link.dataset.previewHack);
    if (manifest) {
      openPreviewModal(manifest);
    }
  });
  document.body.dataset.previewLinksBound = "true";
}

/** Render YouTube trailer, release download, boxart, and preview links into a container. */
export function renderHackLinks(container, { trailerUrl, downloadUrl, boxartLinks, id, title, previews, previewsFolder } = {}) {
  const parts = [];
  if (trailerUrl) {
    parts.push(
      `<a href="${trailerUrl}" target="_blank" rel="noopener noreferrer">YouTube Trailer</a>`
    );
  }
  if (downloadUrl) {
    parts.push(
      `<a href="${assetUrl(downloadUrl)}" download>${releaseZipLabel(downloadUrl)}</a>`
    );
  }
  const boxarts = boxartLinks ?? [];
  const boxartPrefix = boxarts.length > 1 ? "Boxarts" : "Boxart";
  for (const { label, url } of boxarts) {
    parts.push(
      `<a href="${url}" target="_blank" rel="noopener noreferrer">${boxartPrefix}: ${label}</a>`
    );
  }
  if ((previews?.length || previewsFolder) && id) {
    parts.push(
      `<a href="#" data-preview-hack="${id}">Previews</a>`
    );
  }
  if (!parts.length) {
    container.hidden = true;
    container.innerHTML = "";
    return;
  }
  container.hidden = false;
  container.innerHTML = parts.join("<br>");
}
