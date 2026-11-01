Ghosts 'n Goblins/Makaimura - Princess Edition v1.0 - by GoodLuckTrying (https://twitter.com/_GoodLuckTrying) & Poody (https://twitter.com/hetagaki_poody)

This is a Ghosts'n Goblins/Makaimura sprite hack that changes Arthur into Princess Prin Prin and vice versa.
Most enemies have also been changed into monter girls.

Version 1.0 Changes:
- Fully replaces Arthur with a Princess Prin Prin.
  - Sprites, life icon, map icon, dialogue.
- Frog transformation changed for the pig in "Son Son".
- Updates the dialogue correcting typos and "Engrish".
- Every enemy sprite has been redone.
- Most enemy attack sprites have been redone.
- Every weapon sprite has been redone.
- Some fire graphics have been redone.
- New logo for both World and Japanese versions.
- Citizen Dolls have been changed into "Capcom Gals", can you name them all?
- Other score items have been changed.
- An Enhanced edition for every supported ROM set. Enhanced smooths crouching and climbing up ladders; it makes no other gameplay changes.
- Use Romdata to load the Enhanced Edition hacks on FB Neo. It's provided.

Currently, FB Neo only supports gngprincess and makprincess.

Patches are included for every other official revision/set. Will require using romdata to load into FB Neo.

Future updates will most likely center around emulator support.
================================================================================
                    COMPATIBLE GHOSTS 'N GOBLINS ROMSETS
================================================================================
Provide a clean copy of one of these complete ROM sets:

gng: Ghosts 'n Goblins (World? set 1)
gnga: Ghosts 'n Goblins (World? set 2)
gngb: Ghosts 'n Goblins (World? set 3)
gngc: Ghosts 'n Goblins (World? set 4)
gngt: Ghosts 'n Goblins (US)
makaimur: Makaimura (Japan)
makaimurb: Makaimura (Japan revision B)
makaimurc: Makaimura (Japan revision C)
makaimurg: Makaimura (Japan revision G)

The original game ROMs are not included. Put each source ROM set beside the
patcher scripts, either in a folder named for the set (for example, `gng\`) or
in a ZIP named for the set (for example, `gng.zip`). ZIPs must contain the ROM
files at their root. If both forms are present, folder output mode uses the
folder; ZIP output mode prefers the ZIP.

================================================================================
                              PATCHING
================================================================================
1. Optionally run the matching `1. verify_*_romset.bat` to check the clean
   source ROM files. Each verifier checks one of the nine source sets listed
   above.
2. Run `2. patch_roms.bat`.
3. Choose one set, all stock sets, all Enhanced sets, or all 18 builds.
4. Choose folder or ZIP output.

The menu's stock entries build these sets:

  gngprincess       Ghosts 'n Goblins - Princess Prin Prin Edition (World? 1)
  gngprincessa      Ghosts 'n Goblins - Princess Prin Prin Edition (World? 2)
  gngprincessb      Ghosts 'n Goblins - Princess Prin Prin Edition (World? 3)
  gngprincessc      Ghosts 'n Goblins - Princess Prin Prin Edition (World? 4)
  gngprincesst      Ghosts 'n Goblins - Princess Prin Prin Edition (US)
  makprincess       Makaimura - Princess Prin Prin Edition
  makprincessb      Makaimura - Princess Prin Prin Edition (Japan revision B)
  makprincessc      Makaimura - Princess Prin Prin Edition (Japan revision C)
  makprincessg      Makaimura - Princess Prin Prin Edition (Japan revision G)

The Enhanced entries build these sets:

  gngprincessenh    Ghosts 'n Goblins - Princess Prin Prin Edition (Enhanced) (World? 1)
  gngprincessaenh   Ghosts 'n Goblins - Princess Prin Prin Edition (Enhanced) (World? 2)
  gngprincessbenh   Ghosts 'n Goblins - Princess Prin Prin Edition (Enhanced) (World? 3)
  gngprincesscenh   Ghosts 'n Goblins - Princess Prin Prin Edition (Enhanced) (World? 4)
  gngprincesstenh   Ghosts 'n Goblins - Princess Prin Prin Edition (Enhanced) (US)
  makprincessenh    Makaimura - Princess Prin Prin Edition (Enhanced)
  makprincessbenh   Makaimura - Princess Prin Prin Edition (Enhanced) (Japan revision B)
  makprincesscenh   Makaimura - Princess Prin Prin Edition (Enhanced) (Japan revision C)
  makprincessgenh   Makaimura - Princess Prin Prin Edition (Enhanced) (Japan revision G)

================================================================================
                               ROMDATA
================================================================================
ROMData files are included under:

  Patcher\Romdata (For FB Neo)
  Patcher\Romdata (Extras)

The Extras folder contains the `gngprincess.dat` and `makprincess.dat` files;
the other Princess stock and Enhanced ROMData files are in the FB Neo folder.
Use the ROMData file matching the set you built, together with that patched
ROM set, following the ROMData workflow for your FB Neo version or frontend.

================================================================================
                                 CREDITS
================================================================================
GoodLuckTrying - Hack developer.
Poody - Artist behind every new sprite.
dink - Checksum-check bypass for the program ROMs and help understanding the ROM sets.
phonymike - Help making the graphics editable with Tile Molester / YY-CHR.
morb - Checksum fix.