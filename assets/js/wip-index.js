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

function buildYoutubeLink(url, label) {
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.target = "_blank";
  anchor.rel = "noopener noreferrer";
  anchor.className = "hack-link-with-icon";

  const img = document.createElement("img");
  img.src = "assets/icons/Youtube.png";
  img.alt = "";
  img.loading = "lazy";
  img.decoding = "async";
  anchor.appendChild(img);

  const text = document.createElement("span");
  text.textContent = label;
  anchor.appendChild(text);
  return anchor;
}

// Build Works in Progress cards from WIP_SECTIONS (generated from assets/source/wip/).
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
      creditLine.className = "card-credits";
      for (const [index, { name, role, url }] of credits.entries()) {
        if (index) creditLine.appendChild(document.createElement("br"));
        if (url) {
          const creditLink = document.createElement("a");
          creditLink.href = url;
          creditLink.target = "_blank";
          creditLink.rel = "noopener noreferrer";
          creditLink.textContent = name;
          creditLine.appendChild(creditLink);
        } else if (name) {
          const strong = document.createElement("strong");
          strong.textContent = name;
          creditLine.appendChild(strong);
        }
        if (role) {
          creditLine.appendChild(document.createTextNode(` — ${role}`));
        }
      }
      card.appendChild(creditLine);
    }

    const previewLink = document.createElement("p");
    previewLink.className = "card-links";
    const links = [];
    if (hack.previewUrl) links.push(buildYoutubeLink(hack.previewUrl, "YouTube Preview"));
    if (hack.trailerUrl) links.push(buildYoutubeLink(hack.trailerUrl, "YouTube Trailer"));
    for (const link of hack.links ?? []) links.push(buildLinkAnchor(link));

    for (const [index, link] of links.entries()) {
      if (index) previewLink.appendChild(document.createElement("br"));
      previewLink.appendChild(link);
    }
    if (hack.id && (hack.previews?.length || hack.previewsFolder)) {
      if (links.length) previewLink.appendChild(document.createElement("br"));
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
