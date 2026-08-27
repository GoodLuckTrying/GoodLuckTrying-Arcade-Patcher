#!/usr/bin/env python3
"""Generate web patcher manifests from verify bats and Patching Layout.csv."""
import csv
import json
import re
import shutil
from pathlib import Path

ROOT = Path(r"c:\Build")
OUT = ROOT / "manifests"

PROJECTS = [
    {
        "id": "ghouls-artoria-v10",
        "title": "Ghouls'n Ghosts: Knight/Maiden Artoria Edition v1.0",
        "trailerUrl": "https://youtu.be/kNsi4sraUQc",
        "icon": "assets/icons/GhoulsArtoria.png",
        "folder": "Ghouls'n Ghosts - Artoria Edition v1.0 by GoodLuckTrying",
        "boxartLinks": [
            {
                "label": "Ghouls'n Ghosts: Knight/Maiden Artoria Edition",
                "url": "https://www.deviantart.com/xxcaesarxx/art/Ghouls-n-Ghosts-Knight-Maiden-Artoria-Edition-1373422334",
            },
            {
                "label": "Daimakaimura: Knight/Maiden Artoria Edition",
                "url": "https://www.deviantart.com/xxcaesarxx/art/Daimakaimura-Knight-Maiden-Artoria-Edition-1373423892",
            },
        ],
        "mode": "dual",  # maiden + knight columns
        "section_names": ["ghouls", "ghoulsu", "daimakai"],
        "builds": {
            "ghoulsmaiden": {"section": "ghouls", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "ghoulsknight": {"section": "ghouls", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "ghoulsumaiden": {"section": "ghoulsu", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "ghoulsuknight": {"section": "ghoulsu", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "daimakaimaiden": {"section": "daimakai", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "daimakaiknight": {"section": "daimakai", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
        },
        "romset_labels": {
            "ghouls": "Ghouls'n Ghosts (World)",
            "ghoulsu": "Ghouls'n Ghosts (USA)",
            "daimakai": "Daimakaimura (Japan)",
        },
        "credits": [
            {
                "name": "GoodLuckTrying",
                "role": "Hack author",
                "url": "https://github.com/GoodLuckTrying",
            },
            {
                "name": "morb / misentropy",
                "role": "Developer behind modifying the “The End” screen artworks, updating the titlescreen, and more help than can be listed.",
            },
            {
                "name": "sleepyren",
                "role": "Artist behind key Artoria frames and the Citizen Doll sprites.",
            },
            {
                "name": "Ian Samson",
                "role": "Artist behind the “The End” screen artworks for both Knight and Maiden Artoria Editions.",
                "url": "https://www.deviantart.com/tran4of3",
            },
        ],
    },
    {
        "id": "gng-enhanced-v10",
        "title": "Ghosts'n Goblins Enhanced v1.0",
        "trailerUrl": "https://youtu.be/1MqTjmTokAo",
        "icon": "assets/icons/GoblinsArthur.png",
        "folder": "Ghosts'n Goblins Enhanced v1.0 by GoodLuckTrying",
        "mode": "single",
        "section_names": [
            "gngenh", "gngaenh", "gngbenh", "gngcenh", "gngtenh",
            "makaimurenh", "makaimurbenh", "makaimurcenh", "makaimurgenh",
        ],
        "builds": {
            "gngenh": {"section": "gngenh", "source": "gng", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "gngaenh": {"section": "gngaenh", "source": "gnga", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "gngbenh": {"section": "gngbenh", "source": "gngb", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "gngcenh": {"section": "gngcenh", "source": "gngc", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "gngtenh": {"section": "gngtenh", "source": "gngt", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "makaimurenh": {"section": "makaimurenh", "source": "makaimur", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "makaimurbenh": {"section": "makaimurbenh", "source": "makaimurb", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "makaimurcenh": {"section": "makaimurcenh", "source": "makaimurc", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
            "makaimurgenh": {"section": "makaimurgenh", "source": "makaimurg", "patchesDir": "patches", "bpsCol": 1, "outCol": 2},
        },
        "romset_labels": {
            "gng": "Ghosts'n Goblins — World (set 1)",
            "gnga": "Ghosts'n Goblins — World (set 2)",
            "gngb": "Ghosts'n Goblins — World (set 3)",
            "gngc": "Ghosts'n Goblins — World (set 4)",
            "gngt": "Ghosts'n Goblins — US (Title)",
            "makaimur": "Makaimura — Japan",
            "makaimurb": "Makaimura — Japan (revision B)",
            "makaimurc": "Makaimura — Japan (revision C)",
            "makaimurg": "Makaimura — Japan (revision G)",
        },
    },
    {
        "id": "gng-artoria-v12",
        "title": "Ghosts'n Goblins: Knight/Maiden Artoria Edition v1.2",
        "trailerUrl": "https://youtu.be/NHejslEFf_g",
        "icon": "assets/icons/GoblinsArtoria.png",
        "folder": "Ghosts'n Goblins - Artoria Edition v1.2 by GoodLuckTrying",
        "boxartLinks": [
            {
                "label": "Knight Artoria Edition",
                "url": "https://www.deviantart.com/xxcaesarxx/art/Ghosts-n-Goblins-Makaimura-Knight-Artoria-Edition-1312785645",
            },
            {
                "label": "Maiden Artoria Edition",
                "url": "https://www.deviantart.com/xxcaesarxx/art/Ghosts-n-Goblins-Makaimura-Maiden-Artoria-Edition-1312786516",
            },
        ],
        "mode": "dual",
        "section_names": [
            "gng", "gnga", "gngb", "gngc", "gngt",
            "makaimur", "makaimurb", "makaimurc", "makaimurg",
            "gngenh", "gngaenh", "gngbenh", "gngcenh", "gngtenh",
            "makaimurenh", "makaimurbenh", "makaimurcenh", "makaimurgenh",
        ],
        "source_map": {
            "gngenh": "gng", "gngaenh": "gnga", "gngbenh": "gngb", "gngcenh": "gngc", "gngtenh": "gngt",
            "makaimurenh": "makaimur", "makaimurbenh": "makaimurb",
            "makaimurcenh": "makaimurc", "makaimurgenh": "makaimurg",
        },
        "builds": {
            "gngmaiden": {"section": "gng", "source": "gng", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknight": {"section": "gng", "source": "gng", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidena": {"section": "gnga", "source": "gnga", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknighta": {"section": "gnga", "source": "gnga", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidenb": {"section": "gngb", "source": "gngb", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknightb": {"section": "gngb", "source": "gngb", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidenc": {"section": "gngc", "source": "gngc", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknightc": {"section": "gngc", "source": "gngc", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaident": {"section": "gngt", "source": "gngt", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknightt": {"section": "gngt", "source": "gngt", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaiden": {"section": "makaimur", "source": "makaimur", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknight": {"section": "makaimur", "source": "makaimur", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaidenb": {"section": "makaimurb", "source": "makaimurb", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknightb": {"section": "makaimurb", "source": "makaimurb", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaidenc": {"section": "makaimurc", "source": "makaimurc", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknightc": {"section": "makaimurc", "source": "makaimurc", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaideng": {"section": "makaimurg", "source": "makaimurg", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknightg": {"section": "makaimurg", "source": "makaimurg", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidenenh": {"section": "gngenh", "source": "gng", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknightenh": {"section": "gngenh", "source": "gng", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidenaenh": {"section": "gngaenh", "source": "gnga", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknightaenh": {"section": "gngaenh", "source": "gnga", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidenbenh": {"section": "gngbenh", "source": "gngb", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknightbenh": {"section": "gngbenh", "source": "gngb", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidencenh": {"section": "gngcenh", "source": "gngc", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknightcenh": {"section": "gngcenh", "source": "gngc", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "gngmaidentenh": {"section": "gngtenh", "source": "gngt", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "gngknighttenh": {"section": "gngtenh", "source": "gngt", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaidenenh": {"section": "makaimurenh", "source": "makaimur", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknightenh": {"section": "makaimurenh", "source": "makaimur", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaidenbenh": {"section": "makaimurbenh", "source": "makaimurb", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknightbenh": {"section": "makaimurbenh", "source": "makaimurb", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaidencenh": {"section": "makaimurcenh", "source": "makaimurc", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknightcenh": {"section": "makaimurcenh", "source": "makaimurc", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
            "makmaidengenh": {"section": "makaimurgenh", "source": "makaimurg", "patchesDir": "patches/maiden_artoria", "bpsCol": 1, "outCol": 2},
            "makknightgenh": {"section": "makaimurgenh", "source": "makaimurg", "patchesDir": "patches/knight_artoria", "bpsCol": 3, "outCol": 4},
        },
        "romset_labels": {
            "gng": "Ghosts'n Goblins — World (set 1)",
            "gnga": "Ghosts'n Goblins — World (set 2)",
            "gngb": "Ghosts'n Goblins — World (set 3)",
            "gngc": "Ghosts'n Goblins — World (set 4)",
            "gngt": "Ghosts'n Goblins — US (Title)",
            "makaimur": "Makaimura — Japan",
            "makaimurb": "Makaimura — Japan (revision B)",
            "makaimurc": "Makaimura — Japan (revision C)",
            "makaimurg": "Makaimura — Japan (revision G)",
        },
        "credits": [
            {
                "name": "GoodLuckTrying",
                "role": "Hack author",
                "url": "https://github.com/GoodLuckTrying",
            },
            {
                "name": "poody",
                "role": "Artist behind every new sprite.",
                "url": "https://twitter.com/hetagaki_poody",
            },
            {
                "name": "dink",
                "role": "Developer behind the checksum check bypass for the program ROMs, and tremendous help understanding the romset.",
            },
            {
                "name": "phonymike",
                "role": "Invaluable help getting the graphics modifiable through Tile Molester / YY-CHR.",
            },
            {
                "name": "morb",
                "role": "Hacker behind death frames' palette changes and checksum fix.",
            },
        ],
    },
]

VERIFY_RE = re.compile(
    r'set "filename=([^"]+)" & set "expected(?:_crc)?=([0-9a-fA-F]{8})"',
    re.IGNORECASE,
)
LABEL_RE = re.compile(r"^([a-z0-9_]+)\s*\((.+?)\)\s*$", re.IGNORECASE)


PREVIEW_EXT = {".png", ".gif", ".jpg", ".jpeg", ".webp"}
WIP_ROOT = ROOT / "assets" / "wip"


def wip_display_title(folder_name: str) -> str:
    title = folder_name
    if title.startswith("Arcade "):
        title = title[7:]
    return re.sub(r" by GoodLuckTrying$", "", title, flags=re.IGNORECASE)


def wip_id(folder_name: str) -> str:
    base = folder_name.lower()
    base = re.sub(r" by goodlucktrying", "", base)
    base = re.sub(r"^arcade ", "", base)
    slug = re.sub(r"[^a-z0-9]+", "-", base).strip("-")
    return f"wip-{slug}"


def scan_wip_hacks() -> tuple[dict, list]:
    """Scan assets/wip/<platform>/<project>/Previews for coming-soon cards."""
    hacks_data: dict = {}
    sections: list = []

    if not WIP_ROOT.is_dir():
        return hacks_data, sections

    for platform_dir in sorted(WIP_ROOT.iterdir()):
        if not platform_dir.is_dir():
            continue
        platform = platform_dir.name
        platform_hacks = []

        for project_dir in sorted(platform_dir.iterdir()):
            previews_dir = project_dir / "Previews"
            if not previews_dir.is_dir():
                continue

            files = [
                f.name
                for f in sorted(previews_dir.iterdir())
                if f.is_file() and f.suffix.lower() in PREVIEW_EXT
            ]
            if not files:
                continue

            hack_id = wip_id(project_dir.name)
            previews_folder = previews_dir.relative_to(ROOT).as_posix()
            entry = {
                "id": hack_id,
                "title": wip_display_title(project_dir.name),
                "platform": platform,
                "previewsFolder": previews_folder,
                "previews": files,
            }
            hacks_data[hack_id] = entry
            platform_hacks.append(entry)
            print(f"  WIP {hack_id}: {len(files)} previews")

        if platform_hacks:
            sections.append({"platform": platform, "hacks": platform_hacks})

    return hacks_data, sections


def scan_previews(project_id: str, folder: str) -> tuple[str, list[str]]:
    """Copy previews into assets/previews/<id>/ for simple web URLs."""
    previews_dir = ROOT / folder / "Previews"
    web_dir = ROOT / "assets" / "previews" / project_id
    web_rel = f"assets/previews/{project_id}"

    if not previews_dir.is_dir():
        return web_rel, []

    web_dir.mkdir(parents=True, exist_ok=True)
    # Clear old copies so removed previews don't linger
    for old in web_dir.iterdir():
        if old.is_file():
            old.unlink()

    files = []
    for f in sorted(previews_dir.iterdir()):
        if f.is_file() and f.suffix.lower() in PREVIEW_EXT:
            shutil.copy2(f, web_dir / f.name)
            files.append(f.name)

    return web_rel, files


def parse_verify_bat(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    roms = {}
    for m in VERIFY_RE.finditer(text):
        roms[m.group(1)] = m.group(2).lower()
    return roms


def parse_csv_sections(csv_path: Path, section_names: list[str]) -> dict[str, list[list[str]]]:
    sections = {}
    current = None
    rows = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        for line in csv.reader(f):
            if not line or all(not c.strip() for c in line):
                if current:
                    sections[current] = rows
                    rows = []
                    current = None
                continue
            first = line[0].strip()
            if first in section_names:
                if current:
                    sections[current] = rows
                current = first
                rows = []
                continue
            if current and first:
                rows.append([c.strip() for c in line])
    if current:
        sections[current] = rows
    return sections


def parse_output_labels(csv_path: Path, section_names: list[str]) -> dict[str, str]:
    """Parse header rows for human-readable output names."""
    labels = {}
    with open(csv_path, newline="", encoding="utf-8") as f:
        for line in csv.reader(f):
            if not line:
                continue
            first = line[0].strip()
            if first not in section_names:
                continue
            for col in (2, 4):
                if len(line) > col and line[col].strip():
                    cell = line[col].strip()
                    # "ghoulsmaiden (Ghouls'n Ghosts - Maiden Artoria Edition (World)"
                    if "(" in cell:
                        name = cell.split("(", 1)[0].strip()
                        label = cell.split("(", 1)[1].strip()
                        # Balance truncated labels from CSV headers
                        open_parens = label.count("(")
                        close_parens = label.count(")")
                        while close_parens < open_parens:
                            label += ")"
                            close_parens += 1
                        labels[name] = label
    return labels


def layout_rows(section_rows: list[list[str]], bps_col: int, out_col: int) -> list[dict]:
    layout = []
    for row in section_rows:
        if not row or not row[0]:
            continue
        src = row[0]
        bps = row[bps_col] if len(row) > bps_col else ""
        out = row[out_col] if len(row) > out_col else src
        if not out:
            out = src
        entry = {"source": src, "output": out}
        if bps and bps.endswith(".bps"):
            entry["patch"] = bps
        layout.append(entry)
    return layout


def build_manifest(project: dict) -> dict:
    patcher = ROOT / project["folder"] / "Patcher"
    csv_path = patcher / "Patching Layout.csv"
    sections = parse_csv_sections(csv_path, project["section_names"])
    labels = parse_output_labels(csv_path, project["section_names"])

    # Collect verify data per source romset
    romsets = {}
    verify_dir = patcher
    source_map = project.get("source_map", {})

    # Determine unique source romsets needed for verification
    sources_needed = set()
    for build_id, cfg in project["builds"].items():
        src = cfg.get("source", cfg["section"])
        sources_needed.add(src)

    for src in sorted(sources_needed):
        bat = verify_dir / f"1. verify_{src}_romset.bat"
        if not bat.exists():
            print(f"  WARN: missing {bat}")
            continue
        romsets[src] = {
            "label": project.get("romset_labels", {}).get(src, src),
            "roms": parse_verify_bat(bat),
        }

    builds = {}
    for build_id, cfg in project["builds"].items():
        section = cfg["section"]
        source = cfg.get("source", section)
        rows = sections.get(section, [])
        layout = layout_rows(rows, cfg["bpsCol"], cfg["outCol"])
        builds[build_id] = {
            "sourceRomset": source,
            "outputZip": f"{build_id}.zip",
            "label": labels.get(build_id, build_id),
            "patchesBase": f"{project['folder']}/Patcher/{cfg['patchesDir']}",
            "layout": layout,
        }

    previews_folder, preview_files = scan_previews(project["id"], project["folder"])

    folder = project["folder"]
    download_rel = f"{folder}/{folder}.zip"
    download_path = ROOT / download_rel

    manifest = {
        "id": project["id"],
        "title": project["title"],
        "patcherRoot": f"{project['folder']}/Patcher",
        "previewsFolder": previews_folder,
        "previews": preview_files,
        "romsets": romsets,
        "builds": builds,
    }
    if project.get("trailerUrl"):
        manifest["trailerUrl"] = project["trailerUrl"]
    if download_path.is_file():
        manifest["downloadUrl"] = download_rel.replace("\\", "/")
    else:
        print(f"  Warning: release zip not found: {download_rel}")
    if project.get("boxartLinks"):
        manifest["boxartLinks"] = project["boxartLinks"]
    if project.get("icon"):
        manifest["icon"] = project["icon"]
    if project.get("credits"):
        manifest["credits"] = project["credits"]
    return manifest


def main():
    OUT.mkdir(exist_ok=True)
    hacks_data = {}
    for project in PROJECTS:
        print(f"Generating {project['id']}...")
        manifest = build_manifest(project)
        out_path = OUT / f"{project['id']}.json"
        out_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        entry = {
            "id": manifest["id"],
            "title": manifest["title"],
            "previewsFolder": manifest["previewsFolder"],
            "previews": manifest["previews"],
        }
        if manifest.get("trailerUrl"):
            entry["trailerUrl"] = manifest["trailerUrl"]
        if manifest.get("downloadUrl"):
            entry["downloadUrl"] = manifest["downloadUrl"]
        if manifest.get("boxartLinks"):
            entry["boxartLinks"] = manifest["boxartLinks"]
        if manifest.get("icon"):
            entry["icon"] = manifest["icon"]
        if manifest.get("credits"):
            entry["credits"] = manifest["credits"]
        hacks_data[project["id"]] = entry
        print(f"  {len(manifest['romsets'])} romsets, {len(manifest['builds'])} builds -> {out_path}")

    hacks_js = ROOT / "assets" / "js" / "hacks-data.js"
    hacks_js.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(hacks_data, indent=2)
    hacks_js.write_text(f"window.HACKS_DATA = {payload};\n", encoding="utf-8")
    print(f"Wrote {hacks_js}")

    print("Scanning WIP previews...")
    wip_data, wip_sections = scan_wip_hacks()
    wip_js = ROOT / "assets" / "js" / "wip-hacks-data.js"
    wip_js.write_text(
        "window.WIP_HACKS_DATA = "
        + json.dumps(wip_data, indent=2)
        + ";\nwindow.WIP_SECTIONS = "
        + json.dumps(wip_sections, indent=2)
        + ";\n",
        encoding="utf-8",
    )
    print(f"Wrote {wip_js} ({len(wip_data)} WIP hacks)")


if __name__ == "__main__":
    main()
