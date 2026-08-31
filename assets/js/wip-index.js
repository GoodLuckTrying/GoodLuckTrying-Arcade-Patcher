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
    if (hack.id && (hack.previews?.length || hack.previewsFolder)) {
      const previewButton = document.createElement("button");
      previewButton.type = "button";
      previewButton.className = "preview-link-button";
      previewButton.dataset.previewHack = hack.id;
      previewButton.textContent = "Previews";
      previewLink.appendChild(previewButton);
      card.appendChild(previewLink);
    }

    li.appendChild(card);
    list.appendChild(li);
  }
}
