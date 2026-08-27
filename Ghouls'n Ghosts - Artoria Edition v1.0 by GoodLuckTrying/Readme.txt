Ghouls'n Ghosts - Knight/Maiden Artoria Edition v1.0 - by GoodLuckTrying (https://github.com/GoodLuckTrying)

This is a Ghouls'n Ghosts sprite hack that changes Arthur's sprites into those of a Maiden/Knight, Artoria.

Version 1.0 Changes:
- Fully replaces Arthur with a Maiden/Knight, Artoria.
  - Sprites, life icon, map icon, dialogue, end screen artworks.
- Updates the dialogue correcting typos, errors and "Engrish", as well as changing mentions of Arthur.
- 3 weapon sprites were visually altered.
- Titlescreen has been updated.
- Citizen Dolls have been updated.
- Both Magician transformations have been changed.


================================================================================
                    COMPATIBLE SOURCE ROMSETS
================================================================================
ghouls     = Ghouls'n Ghosts (World)
ghoulsu    = Ghouls'n Ghosts (USA)
daimakai   = Daimakaimura (Japan)
================================================================================
                    PATCHED OUTPUT SETS
================================================================================

================================================================================
			Knight Artoria Edition
================================================================================
ghoulsknight     = Ghouls'n Ghosts - Knight Artoria Edition (World)
ghoulsuknight    = Ghouls'n Ghosts - Knight Artoria Edition (USA)
daimakaiknight   = Daimakaimura - Knight Artoria Edition (Japan)

================================================================================
			Maiden Artoria Edition
================================================================================
ghoulsmaiden     = Ghouls'n Ghosts - Maiden Artoria Edition (World)
ghoulsumaiden    = Ghouls'n Ghosts - Maiden Artoria Edition (USA)
daimakaimaiden   = Daimakaimura - Maiden Artoria Edition (Japan)

================================================================================
                    HOW TO PATCH
================================================================================
1. Verify your source roms (optional but recommended)
   - 1. verify_ghouls_romset.bat     -> ghouls\
   - 1. verify_ghoulsu_romset.bat    -> ghoulsu\
   - 1. verify_daimakai_romset.bat   -> daimakai\

   Each script checks that every file is present and that its CRC32 matches
   the expected stock dump.

2. Patch
   - 2. patch_roms.bat
       1. Patch ghoulsmaiden     [Maiden Artoria (World)]
       2. Patch ghoulsknight     [Knight Artoria (World)]
       3. Patch ghoulsumaiden    [Maiden Artoria (USA)]
       4. Patch ghoulsuknight    [Knight Artoria (USA)]
       5. Patch daimakaimaiden   [Maiden Artoria (Japan)]
       6. Patch daimakaiknight   [Knight Artoria (Japan)]
       7. Patch all
       8. Exit

   Then choose output format:
     1. Folders  - read ghouls\ / ghoulsu\ / daimakai\
                   write matching *maiden\ / *knight\ folders
     2. Zip files - read ghouls.zip / ghoulsu.zip / daimakai.zip
                    write matching .zip outputs

   Patched ROMs are written next to these scripts.

   Notes:
   - Uses BPS patches via Flips. Each patched file reports CRC OK or CRC WRONG
     on the same line (BPS source/target checksum vs the ROM).
   - Which patch applies to which ROM is listed in Patching Layout.csv.

Requirements:
  - flips.exe in this folder (https://github.com/Alcaro/Flips/releases)
  - BPS patches under patches\maiden_artoria and patches\knight_artoria
  - Patching Layout.csv
  - PowerShell (used by 2. patch_roms.bat)


================================================================================
                    EMULATOR SUPPORT
================================================================================
FB Neo
HBMame
MAME 2003-Plus

Driver names (parent: ghouls):
  ghoulsmaiden      Maiden Artoria (World)
  ghoulsknight      Knight Artoria (World)
  ghoulsumaiden     Maiden Artoria (USA)
  ghoulsuknight     Knight Artoria (USA)
  daimakaimaiden    Maiden Artoria (Japan)
  daimakaiknight    Knight Artoria (Japan)

================================================================================
			How to load into MAME
================================================================================
1. Use patcher, then within "Patcher/patches" folder, you'll find 4 .bat files.
2. Copy and paste the respective Remove____.bat file in the rom you intend to use in MAME and run it. It'll rename all files to factory name. For example, run it in "ghoulsmaiden".
3. Copy the folder into your MAME roms folder and rename it to the stock romset's name, so ghoulsmaiden > ghouls.
4. Sideload the romset by making a .bat for the desired version in the root (In the folder here mame.exe is).
The .bat will only have this line:
mame.exe ghouls


Credits:
morb/misentropy: Developer behind figuring out the means to modify the roms that had the "The End" screen artworks, updating the titlescreen, and more help than I can list.
sleepyren: Artist behind key Artoria frames and the Citizen Doll sprites.
tran4of3: Artist behind the "The End" screen artworks for both Knight and Maiden Artoria Editions.
