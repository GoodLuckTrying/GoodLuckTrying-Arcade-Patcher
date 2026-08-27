GHOSTS 'N GOBLINS / MAKAIMURA - ENHANCED HACKS
==============================================

This patcher builds Enhanced romsets from vanilla stock ROMs plus BPS control
ROM patches. Outputs match the sets under Enhanced Hacks Romsets Reference.
Artoria Maiden/Knight editions are not part of this patcher.

You must provide your own stock ROM folders (same directory as these scripts).

Stock sources (input):
  gng        = Ghosts'n Goblins (World? set 1)
  gnga       = Ghosts'n Goblins (World? set 2)
  gngb       = Ghosts'n Goblins (World? set 3)
  gngc       = Ghosts'n Goblins (World? set 4)
  gngt       = Ghosts'n Goblins (US)
  makaimur   = Makaimura (Japan revision A?)
  makaimurb  = Makaimura (Japan revision B)
  makaimurc  = Makaimura (Japan revision C)
  makaimurg  = Makaimura (Japan revision G)

OUTPUTS
-------

  gngenh       <- gng        Ghosts'n Goblins (Enhanced) (World? set 1)
  gngaenh      <- gnga       Ghosts'n Goblins (Enhanced) (World? set 2)
  gngbenh      <- gngb       Ghosts'n Goblins (Enhanced) (World? set 3)
  gngcenh      <- gngc       Ghosts'n Goblins (Enhanced) (World? set 4)
  gngtenh      <- gngt       Ghosts'n Goblins (Enhanced) (US)
  makaimurenh  <- makaimur   Makaimura (Enhanced) (Japan revision A?)
  makaimurbenh <- makaimurb  Makaimura (Enhanced) (Japan revision B)
  makaimurcenh <- makaimurc  Makaimura (Enhanced) (Japan revision C)
  makaimurgenh <- makaimurg  Makaimura (Enhanced) (Japan revision G)

HOW TO USE THE .BAT FILES
-------------------------

1. Verify (optional but recommended)
   Each script name matches the stock ROM folder it reads:

   - 1. verify_gng_romset.bat       -> `gng`
   - 1. verify_gnga_romset.bat      -> `gnga`
   - 1. verify_gngb_romset.bat      -> `gngb`
   - 1. verify_gngc_romset.bat      -> `gngc`
   - 1. verify_gngt_romset.bat      -> `gngt`
   - 1. verify_makaimur_romset.bat  -> `makaimur`
   - 1. verify_makaimurb_romset.bat  -> `makaimurb`
   - 1. verify_makaimurc_romset.bat  -> `makaimurc`
   - 1. verify_makaimurg_romset.bat  -> `makaimurg`

   Every verify script checks presence and compares each file’s CRC32 to the
   expected value. Fix or replace ROMs if anything is missing or fails.

2. Patch
   - 2. patch_roms.bat — menu:
       1–9    Enhanced builds (gngenh … makaimurgenh)
        10    patch all (9)
        11    exit

   Patched ROMs are written next to these scripts in the folders (or zips) above.

Requirements: flips.exe in this folder; BPS files in the `patches` folder
(root, not subfolders); layout from Patching Layout.csv.
Reference romsets: Enhanced Hacks Romsets Reference\
