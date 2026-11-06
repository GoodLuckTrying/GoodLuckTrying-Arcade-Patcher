function sendEvent(name, parameters) {
  if (typeof window.gtag === "function") {
    window.gtag("event", name, parameters);
  }
}

function elementLabel(element) {
  const cardTitle = element.closest(".card")?.querySelector("h3")?.textContent;
  const strongLabel = element.closest(".community-link")?.querySelector("strong")?.textContent;
  const label = element.getAttribute("aria-label") || cardTitle || strongLabel || element.textContent || element.id;
  return label?.trim().replace(/\s+/g, " ").slice(0, 100) || element.type || element.tagName.toLowerCase();
}

function catalogName(element) {
  return element.closest("#wip") ? "wip" : "games";
}

export function initInteractionAnalytics() {
  document.addEventListener("click", (event) => {
    const element = event.target.closest("a, button, input[type='file'], input[type='radio']");
    if (!element) return;

    const anchor = element.closest("a");
    const card = element.closest("[data-hack], [data-wip-hack]");
    const parameters = {
      element_type: element.matches("[data-page-view]") || element.closest(".site-nav") ? "navigation" :
        element.matches("[data-sort]") ? "sort" :
          element.matches("button") ? "button" :
            element.matches("input") ? "input" :
              element.closest(".community-link") ? "contact_link" :
                element.closest(".card") ? "hack_card" : "link",
      element_label: elementLabel(element),
      page_section: element.closest(".page-view")?.id || (element.closest("header") ? "header" : "other"),
    };

    const hackId = card?.dataset.hack || card?.dataset.wipHack;
    if (hackId) parameters.hack_id = hackId;
    if (anchor) parameters.link_domain = anchor.hostname || location.hostname;

    if (element.matches("[data-sort]")) {
      parameters.catalog = catalogName(element);
      parameters.sort_by = element.dataset.sort;
      parameters.sort_direction = element.getAttribute("aria-label")?.includes("descending") ? "descending" : "ascending";
      sendEvent("catalog_sort", parameters);
      return;
    }

    if (element.matches("input[type='file']")) {
      sendEvent("rom_file_picker_open", parameters);
      return;
    }

    sendEvent("site_click", parameters);
  });

  document.addEventListener("change", (event) => {
    const element = event.target;
    if (element.matches("select[id$='platform-filter'], select[id$='game-filter']")) {
      sendEvent("catalog_filter", {
        catalog: catalogName(element),
        filter_type: element.id.includes("platform") ? "console" : "game",
        filter_value: element.selectedOptions[0]?.textContent || "unknown",
      });
      return;
    }

    if (element.matches("input[type='file']")) {
      sendEvent("rom_upload_selected", {
        page_section: "patcher",
        hack_id: new URLSearchParams(location.search).get("hack") || "unknown",
      });
      return;
    }

    if (element.matches("input[type='radio'][name='build']")) {
      sendEvent("patch_build_selected", {
        page_section: "patcher",
        hack_id: new URLSearchParams(location.search).get("hack") || "unknown",
        build_id: element.value,
      });
    }
  });
}
