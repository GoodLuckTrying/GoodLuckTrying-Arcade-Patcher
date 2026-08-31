import { assetUrl, resolveAssetUrl } from "./repo-path.js";

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

    const closeModal = () => {
      modal.classList.remove("is-open");
      document.body.classList.remove("preview-modal-open");
    };

    modal.addEventListener("click", (event) => {
      const closeTarget = event.target.closest("[data-close-preview-modal]");
      if (closeTarget) {
        closeModal();
        return;
      }
      if (event.target === modal) {
        closeModal();
      }
    });

    modal.querySelector(".preview-modal__close")?.addEventListener("click", () => {
      closeModal();
    });

    const dialog = modal.querySelector(".preview-modal__dialog");
    dialog?.addEventListener(
      "wheel",
      (event) => {
        if (!dialog.scrollHeight || dialog.scrollHeight <= dialog.clientHeight) return;
        const atTop = dialog.scrollTop <= 0 && event.deltaY < 0;
        const atBottom = dialog.scrollTop + dialog.clientHeight >= dialog.scrollHeight && event.deltaY > 0;
        if (!atTop && !atBottom) {
          event.preventDefault();
          event.stopPropagation();
          dialog.scrollTop += event.deltaY;
        }
      },
      { passive: false }
    );

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && modal.classList.contains("is-open")) {
        closeModal();
      }
    });
  }

  const content = modal.querySelector(".preview-modal__content");
  content.replaceChildren();

  const title = document.createElement("h2");
  title.textContent = manifest.title;
  content.appendChild(title);

  const gallery = document.createElement("div");
  gallery.className = "preview-gallery";

  modal.classList.add("is-open");
  document.body.classList.add("preview-modal-open");
  requestAnimationFrame(() => {
    const dialog = modal.querySelector(".preview-modal__dialog");
    if (dialog) {
      dialog.scrollTop = 0;
    }
  });

  for (const file of manifest.previews) {
    const src = resolveAssetUrl(manifest.previewsFolder, file);
    const anchor = document.createElement("a");
    anchor.href = src;
    anchor.target = "_blank";
    anchor.rel = "noopener noreferrer";
    anchor.className = "preview-gallery__item";

    const img = document.createElement("img");
    img.src = src;
    img.alt = `${manifest.title} preview ${file}`;
    img.loading = "lazy";
    img.decoding = "async";
    anchor.appendChild(img);
    gallery.appendChild(anchor);
  }

  content.appendChild(gallery);
  modal.classList.add("is-open");
}

if (!document.body.dataset.previewLinksBound) {
  document.addEventListener("click", (event) => {
    const trigger = event.target.closest("a[data-preview-hack], button[data-preview-hack]");
    if (!trigger) return;
    event.preventDefault();
    const manifest = previewManifestFor(trigger.dataset.previewHack);
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
      `<button type="button" class="preview-link-button" data-preview-hack="${id}">Previews</button>`
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
