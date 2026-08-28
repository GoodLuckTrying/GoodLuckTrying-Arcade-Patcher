import { assetUrl } from "./repo-path.js";

function releaseZipLabel(downloadUrl) {
  const filename = downloadUrl.split("/").pop() ?? downloadUrl;
  return `Download ${filename}`;
}

/** Render YouTube trailer, release download, and boxart links into a container. */
export function renderHackLinks(container, { trailerUrl, downloadUrl, boxartLinks } = {}) {
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
  if (!parts.length) {
    container.hidden = true;
    container.innerHTML = "";
    return;
  }
  container.hidden = false;
  container.innerHTML = parts.join("<br>");
}
