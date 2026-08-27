GHOULS 'N GHOSTS - ARTORIA EDITIONS
===================================

You must provide your own ROM set (same directory as these scripts).
Source name matches the section in Patching Layout.csv:

  ghouls    = Ghouls'n Ghosts (World)
  ghoulsu   = Ghouls'n Ghosts (USA)
  daimakai  = Daimakaimura (Japan)

Use a `ghouls` / `ghoulsu` / `daimakai` folder, or the matching `.zip` if you choose zip mode.


HOW TO USE
----------

1. Verify (optional but recommended)

   - 1. verify_ghouls_romset.bat      (World)
   - 1. verify_ghoulsu_romset.bat     (USA)
   - 1. verify_daimakai_romset.bat    (Japan)

   Checks that every file for that set is present and matches the expected CRC32.
   Fix any [MISSING] or [FAIL] results before patching.


2. Patch

   - 2. patch_roms.bat

   Menu (World, USA, Japan):

     1. Patch ghoulsmaiden    — Ghouls'n Ghosts - Maiden Artoria Edition (World)
     2. Patch ghoulsknight    — Ghouls'n Ghosts - Knight Artoria Edition (World)
     3. Patch ghoulsumaiden   — Ghouls'n Ghosts - Maiden Artoria Edition (USA)
     4. Patch ghoulsuknight   — Ghouls'n Ghosts - Knight Artoria Edition (USA)
     5. Patch daimakaimaiden  — Daimakaimura - Maiden Artoria Edition (Japan)
     6. Patch daimakaiknight  — Daimakaimura - Knight Artoria Edition (Japan)
     7. Patch all
     8. Exit

   Then choose output format:

     1. Folders   — read ghouls\ / ghoulsu\ / daimakai\
                    write matching *maiden\ / *knight\ folders
     2. Zip files — read ghouls.zip / ghoulsu.zip / daimakai.zip
                    write matching .zip outputs
                    (falls back to the folder if no zip is present)

   Patched ROMs are written next to these scripts.

   Notes:
   - Works even if this folder's path contains parentheses.
   - Uses BPS patches via Flips. A checksum mismatch (wrong ROM) is an error;
     Flips' message is printed on failure.
   - Zip output is only created if patching had no errors.
   - USA (ghoulsu) shares World graphics patches. CPU ROMs use dmu_* BPS
     patches (including placeholders until USA-specific program patches exist).


REQUIREMENTS
------------

  - flips.exe in this folder
    (https://github.com/Alcaro/Flips/releases)

  - BPS patches under:
      patches\maiden_artoria
      patches\knight_artoria

  - Patching Layout.csv (source names, patch names, and output names)

  - PowerShell (used by 2. patch_roms.bat via Apply-PatchLayout.ps1)
