GHOSTS 'N GOBLINS / MAKAIMURA - PRINCESS PRIN PRIN EDITION
==========================================================

This patcher builds the nine stock Princess editions and their nine Enhanced
gameplay versions. The BPS patches were generated from the final ROM sets in
`Built Working ROMs`; those reference builds are not needed to use the patcher.

REQUIRED FILES
--------------

Keep `2. patch_roms.bat`, `Apply-PatchLayout.ps1`, `Patching Layout.csv`,
`flips.exe`, and `patches\princess\` together.

For each edition, provide its clean source ROM set in a folder beside the
scripts or as a ZIP with the ROM files at its root:

  gng        Ghosts 'n Goblins (World set 1)
  gnga       Ghosts 'n Goblins (World set 2)
  gngb       Ghosts 'n Goblins (World set 3)
  gngc       Ghosts 'n Goblins (World set 4)
  gngt       Ghosts 'n Goblins (USA)
  makaimur   Makaimura (Japan)
  makaimurb  Makaimura (Japan revision B)
  makaimurc  Makaimura (Japan revision C)
  makaimurg  Makaimura (Japan revision G)

If both a folder and ZIP exist for a set, the folder is used. Use legally
obtained ROMs that match the selected source set.

HOW TO USE
----------

1. Optionally run the matching `1. verify_*_romset.bat` to check a clean
   source set.
2. Run `2. patch_roms.bat`.
3. Select one edition or a group, then choose ROM folders or ZIP archives.

The nine stock output folders are `gngprincess`, `gngprincessa`,
`gngprincessb`, `gngprincessc`, `gngprincesst`, `makprincess`,
`makprincessb`, `makprincessc`, and `makprincessg`. Enhanced output names
append `enh`, for example `gngprincessenh`. ZIP mode creates archives with the
same names beside the scripts.

Outputs are rebuilt from the selected clean source set. BPS patches are stored
in `patches\princess`; unchanged ROMs are copied and renamed as specified by
the layout. `Patching Layout.csv` groups each source set with Princess and
Princess Enhanced patch/output columns side by side, matching the Artoria
patcher's layout.
