import { assetUrl } from "./repo-path.js";

/** Render YouTube trailer, release download, and box art links into a container. */
export function renderHackLinks(container, { trailerUrl, downloadUrl, boxartLinks } = {}) {
  const parts = [];
  if (trailerUrl) {
    parts.push(
      `<a href="${trailerUrl}" target="_blank" rel="noopener noreferrer">YouTube trailer</a>`
    );
  }
  if (downloadUrl) {
    parts.push(`<a href="${assetUrl(downloadUrl)}" download>Download</a>`);
  }
  for (const { label, url } of boxartLinks ?? []) {
    parts.push(
      `<a href="${url}" target="_blank" rel="noopener noreferrer">Box art: ${label}</a>`
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
