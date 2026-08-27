Ghosts 'n Goblins / Makaimura - Enhanced v1.0 - by GoodLuckTrying (https://github.com/GoodLuckTrying)

This is a Ghosts'n Goblins / Makaimura QOL hack. It does not change sprites or
story content. Crouch and climbing ladders feel smoother / more natural. No further
gameplay changes.

Version 1.0:
- Enhanced Edition makes crouch and climbing up ladders feel smooth/natural. No further changes to gameplay.
- Upated titlescreen to include vanilla text + credits.
- Only the main sets, gng and makaimur, have a supported Enhanced Edition on FB Neo.
 - Use Romdata for the rest.

================================================================================
                    COMPATIBLE STOCK ROMSETS (INPUT)
================================================================================
gng: Ghosts 'n Goblins (World? set 1)
gnga: Ghosts 'n Goblins (World? set 2)
gngb: Ghosts 'n Goblins (World? set 3)
gngc: Ghosts 'n Goblins (World? set 4)
gngt: Ghosts 'n Goblins (US)
makaimur: Makaimura (Japan revision A?)
makaimurb: Makaimura (Japan revision B)
makaimurc: Makaimura (Japan revision C)
makaimurg: Makaimura (Japan revision G)
================================================================================
			Enhanced Outputs
================================================================================
gngenh: Ghosts 'n Goblins (Enhanced) (World? set 1)
gngaenh: Ghosts 'n Goblins (Enhanced) (World? set 2)
gngbenh: Ghosts 'n Goblins (Enhanced) (World? set 3)
gngcenh: Ghosts 'n Goblins (Enhanced) (World? set 4)
gngtenh: Ghosts 'n Goblins (Enhanced) (US)
makaimurenh: Makaimura (Enhanced) (Japan revision A?)
makaimurbenh: Makaimura (Enhanced) (Japan revision B)
makaimurcenh: Makaimura (Enhanced) (Japan revision C)
makaimurgenh: Makaimura (Enhanced) (Japan revision G)
================================================================================
			Patching Instructions
================================================================================
You must provide your own vanilla ROM folders (or .zip of the same name). Place each
next to the scripts in the Patcher folder.

HOW TO USE THE .BAT FILES
-------------------------

1. Verify your roms (optional but recommended)
   Each script checks presence and CRC32 for its matching stock folder:
   - 1. verify_gng_romset.bat       -> gng
   - 1. verify_gnga_romset.bat      -> gnga
   - 1. verify_gngb_romset.bat      -> gngb
   - 1. verify_gngc_romset.bat      -> gngc
   - 1. verify_gngt_romset.bat      -> gngt
   - 1. verify_makaimur_romset.bat  -> makaimur
   - 1. verify_makaimurb_romset.bat -> makaimurb
   - 1. verify_makaimurc_romset.bat -> makaimurc
   - 1. verify_makaimurg_romset.bat -> makaimurg

2. Patch
   - 2. patch_roms.bat — choose one:
	1. Patch gngenh        [Ghosts'n Goblins (Enhanced) (World? set 1)]
	2. Patch gngaenh       [Ghosts'n Goblins (Enhanced) (World? set 2)]
	3. Patch gngbenh       [Ghosts'n Goblins (Enhanced) (World? set 3)]
	4. Patch gngcenh       [Ghosts'n Goblins (Enhanced) (World? set 4)]
	5. Patch gngtenh       [Ghosts'n Goblins (Enhanced) (US)]
	6. Patch makaimurenh   [Makaimura (Enhanced) (Japan revision A?)]
	7. Patch makaimurbenh  [Makaimura (Enhanced) (Japan revision B)]
	8. Patch makaimurcenh  [Makaimura (Enhanced) (Japan revision C)]
	9. Patch makaimurgenh  [Makaimura (Enhanced) (Japan revision G)]
	10. Patch all (9)
	11. Exit

   You can write folders or .zip files. Layout comes from Patching Layout.csv;
   BPS patches live in Patcher\patches\.

Requirements: flips.exe in the Patcher folder.

================================================================================
			How to load into MAME
================================================================================
1. Patch the roms with the Patcher.
2. Keep the Enhanced output folder/zip names (gngenh, makaimurenh, …) or rename
   files to match the parent vanilla set if you are sideloading over that parent.
3. Launch the parent set from a .bat next to mame.exe, for example:
mame.exe gng
mame.exe gnga
mame.exe makaimur
...
