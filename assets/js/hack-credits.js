/** Render per-hack credits into a list (patcher pages only). */
export function renderHackCredits(section, listEl, { credits } = {}) {
  const items = credits ?? [];
  if (!items.length) {
    section.hidden = true;
    listEl.replaceChildren();
    return;
  }

  section.hidden = false;
  listEl.replaceChildren();

  for (const { name, role, url } of items) {
    const li = document.createElement("li");

    if (url) {
      const link = document.createElement("a");
      link.href = url;
      link.target = "_blank";
      link.rel = "noopener noreferrer";
      link.textContent = name;
      li.appendChild(link);
    } else {
      const strong = document.createElement("strong");
      strong.textContent = name;
      li.appendChild(strong);
    }

    if (role) {
      li.appendChild(document.createTextNode(` — ${role}`));
    }

    listEl.appendChild(li);
  }
}
