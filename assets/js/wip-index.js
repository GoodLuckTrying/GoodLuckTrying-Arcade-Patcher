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

/** Build Works in Progress cards from WIP_SECTIONS (generated from assets/wip/). */
export function renderWipSection(sectionEl, sections) {
  const list = sectionEl.querySelector("#wip-cards");
  if (!sections?.length) {
    sectionEl.hidden = true;
    return;
  }

  const hacks = sections.flatMap(({ hacks: platformHacks }) => platformHacks);
  if (!hacks.length) {
    sectionEl.hidden = true;
    return;
  }

  sectionEl.hidden = false;
  list.replaceChildren();

  for (const hack of hacks) {
    const li = document.createElement("li");
    li.dataset.wipHack = hack.id;

    const card = document.createElement("article");
    card.className = "card card-wip";

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

    const blurb = document.createElement("p");
    blurb.textContent = "WIP";
    card.appendChild(blurb);

    const credits = hack.credits ?? [];
    if (credits.length) {
      const creditLine = document.createElement("p");
      const creditLink = document.createElement("a");
      creditLink.href = credits[0].url || "https://twitter.com/hetagaki_poody";
      creditLink.target = "_blank";
      creditLink.rel = "noopener noreferrer";
      creditLink.textContent = "Poody";
      creditLine.appendChild(document.createTextNode("Co-author: "));
      creditLine.appendChild(creditLink);
      creditLine.appendChild(document.createTextNode(" — all sprites done by him."));
      card.appendChild(creditLine);
    }

    const previewLink = document.createElement("p");
    previewLink.className = "card-links";
    for (const [index, link] of (hack.links ?? []).entries()) {
      if (index) previewLink.appendChild(document.createElement("br"));
      previewLink.appendChild(buildLinkAnchor(link));
    }
    if (hack.id && (hack.previews?.length || hack.previewsFolder)) {
      if (hack.links?.length) previewLink.appendChild(document.createElement("br"));
      const previewButton = document.createElement("button");
      previewButton.type = "button";
      previewButton.className = "preview-link-button";
      previewButton.dataset.previewHack = hack.id;
      previewButton.textContent = "Previews";
      previewLink.appendChild(previewButton);
    }
    if (previewLink.childNodes.length) {
      card.appendChild(previewLink);
    }

    li.appendChild(card);
    list.appendChild(li);
  }
}
