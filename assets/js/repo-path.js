/** Repo-relative URL helpers. */

export function getRepoBase() {
  const meta = document.querySelector('meta[name="repo-base"]')?.content?.trim();
  if (meta) return meta.replace(/\/$/, "");

  if (location.protocol === "file:") return "";

  const parts = location.pathname.split("/").filter(Boolean);
  const last = parts[parts.length - 1] ?? "";
  if (parts.length >= 2 && /\.html?$/i.test(last)) {
    return "/" + parts.slice(0, -1).join("/");
  }
  return "";
}

export function repoUrl(...parts) {
  const joined = parts.filter(Boolean).join("/");
  return joined
    .split("/")
    .map((seg) => encodeURIComponent(seg).replace(/'/g, "%27"))
    .join("/");
}

/**
 * Path to an asset. Uses relative paths when possible so file:// works.
 * Project pages use /RepoName/assets/... via detected or meta base.
 */
export function assetUrl(...parts) {
  const base = getRepoBase();
  const path = repoUrl(...parts);
  if (base) return `${base}/${path}`;
  return path;
}

/** Full URL for fetch/img — resolves relative to the current HTML file. */
export function resolveAssetUrl(...parts) {
  const href = assetUrl(...parts);
  if (/^https?:\/\//i.test(href)) return href;
  if (href.startsWith("/")) {
    return new URL(href, location.origin).href;
  }
  return new URL(href, location.href).href;
}

export function isFileProtocol() {
  return location.protocol === "file:";
}

/** Set the browser tab favicon from a repo-relative asset path. */
export function setPageIcon(...parts) {
  const href = assetUrl(...parts);
  let link = document.querySelector('link[rel="icon"]');
  if (!link) {
    link = document.createElement("link");
    link.rel = "icon";
    link.type = "image/png";
    document.head.appendChild(link);
  }
  link.href = href;
}
