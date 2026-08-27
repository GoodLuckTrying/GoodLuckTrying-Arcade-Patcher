GHOSTS 'N GOBLINS / MAKAIMURA - ARTORIA EDITIONS
================================================

You must provide your own ROM folders (same directory as these scripts).
Each folder name matches a section in Patching Layout.csv:

Stock sources:
  gng        = Ghosts 'n Goblins (World? 1)
  gnga       = Ghosts 'n Goblins (World? 2)
  gngb       = Ghosts 'n Goblins (World? 3)
  gngc       = Ghosts 'n Goblins (World? 4)
  gngt       = Ghosts 'n Goblins (USA)
  makaimur   = Makaimura (Japan)
  makaimurb  = Makaimura (Japan revision B)
  makaimurc  = Makaimura (Japan revision C)
  makaimurg  = Makaimura (Japan revision G)

Enhanced Artoria builds use those same stock source folders. They write
`*enh` output folders/files (Artoria + control-feel).

HOW TO USE THE .BAT FILES
-------------------------

1. Verify (optional but recommended)
   Each script name matches the ROM folder it reads (same name as the folder):

   - 1. verify_gng_romset.bat       -> `gng`
   - 1. verify_gnga_romset.bat      -> `gnga`
   - 1. verify_gngb_romset.bat      -> `gngb`
   - 1. verify_gngc_romset.bat      -> `gngc`
   - 1. verify_gngt_romset.bat       -> `gngt`
   - 1. verify_makaimur_romset.bat   -> `makaimur`
   - 1. verify_makaimurb_romset.bat  -> `makaimurb`
   - 1. verify_makaimurc_romset.bat  -> `makaimurc`
   - 1. verify_makaimurg_romset.bat  -> `makaimurg`

   Fix or replace ROMs if anything is missing. Only `1. verify_gngb_romset.bat`
   compares files to expected CRCs; the other verify scripts check presence and
   print CRC32 for reference (no expected-value match).

2. Patch
   - 2. patch_roms.bat — menu:
       1–18   stock Artoria builds (gngmaiden … makknightg)
      19–36   Enhanced Artoria builds (gngmaidenenh … makknightgenh)
         37   patch all stock (18)
         38   patch all Enhanced (18)
         39   patch all (36)
         40   exit

   Stock build types and output folders (Maiden / Knight pairs):

     gngmaiden / gngknight           -> folders gngmaiden, gngknight (World? 1)
     gngmaidena / gngknighta         -> gngmaidena, gngknighta (World? 2 / ROM folder gnga)
     gngmaidenb / gngknightb         -> gngmaidenb, gngknightb
     gngmaidenc / gngknightc         -> gngmaidenc, gngknightc
     gngmaident / gngknightt         -> gngmaident, gngknightt  (USA / gngt)
     makmaiden / makknight           -> makmaiden, makknight
     makmaidenb / makknightb         -> makmaidenb, makknightb
     makmaidenc / makknightc         -> makmaidenc, makknightc
     makmaideng / makknightg         -> makmaideng, makknightg

   Enhanced builds read the same stock folders and write `*enh` outputs, e.g.:

     gngmaidenenh / gngknightenh     <- gng
     gngmaidenaenh / gngknightaenh   <- gnga
     … same pattern through makmaidengenh / makknightgenh <- makaimurg

   Patched ROMs are written next to these scripts in the folders above.

Requirements: flips.exe in this folder; BPS files under patches\maiden_artoria
and patches\knight_artoria; layout from Patching Layout.csv.
