function getLinkIcon(label = "", url = "") {
  const haystack = `${label} ${url}`.toLowerCase();
  if (haystack.includes("youtube") || haystack.includes("youtu.be")) return "assets/icons/Youtube.png";
  if (haystack.includes("deviant") || haystack.includes("deviantart")) return "assets/icons/DeviantART.png";
  if (haystack.includes(".zip") || haystack.includes("download")) return "assets/icons/Winzip.png";
  return "";
}

function buildLinkAnchor(link) {
  const anchor = document.createElement("a");
  anchor.href = link.url;
  anchor.target = "_blank";
  anchor.rel = "noopener noreferrer";
  anchor.className = "hack-link-with-icon";

  const iconPath = getLinkIcon(link.label, link.url);
  if (iconPath) {
    const img = document.createElement("img");
    img.src = iconPath;
    img.alt = "";
    img.loading = "lazy";
    img.decoding = "async";
    anchor.appendChild(img);
  }

  const label = document.createElement("span");
  label.textContent = link.label;
  anchor.appendChild(label);
  return anchor;
}

/** Build external-link cards for hacks that do not have a browser patcher. */
export function renderOtherSection(sectionEl, hacks) {
  const list = sectionEl.querySelector("#other-cards");
  if (!hacks?.length) {
    sectionEl.hidden = true;
    return;
  }

  list.replaceChildren();
  for (const hack of hacks) {
    const li = document.createElement("li");
    const card = document.createElement("article");
    card.className = "card card-other";

    const platform = document.createElement("p");
    platform.className = "card-platform";
    platform.textContent = hack.platform;
    card.appendChild(platform);

    const preview = document.createElement("div");
    preview.className = "preview-slideshow card-preview";
    preview.dataset.previewHack = hack.id;
    preview.hidden = true;
    card.appendChild(preview);

    const title = document.createElement("h3");
    title.textContent = hack.title;
    card.appendChild(title);

    const links = document.createElement("p");
    links.className = "card-links";
    for (const [index, link] of (hack.links ?? []).entries()) {
      if (index) links.appendChild(document.createElement("br"));
      links.appendChild(buildLinkAnchor(link));
    }
    if (hack.id && (hack.previews?.length || hack.previewsFolder)) {
      if (hack.links?.length) links.appendChild(document.createElement("br"));
      const previewButton = document.createElement("button");
      previewButton.type = "button";
      previewButton.className = "preview-link-button";
      previewButton.dataset.previewHack = hack.id;
      previewButton.textContent = "Previews";
      links.appendChild(previewButton);
    }
    card.appendChild(links);
    li.appendChild(card);
    list.appendChild(li);
  }
}