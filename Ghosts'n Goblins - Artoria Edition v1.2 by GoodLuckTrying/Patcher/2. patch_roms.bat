@echo off
setlocal enabledelayedexpansion

echo ==================== FLIPS ROM PATCHER ====================
echo    Layout: Patching Layout.csv
echo.

rem Check if flips.exe exists in script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
if not exist "%SCRIPT_DIR%\flips.exe" (
    echo ERROR: flips.exe not found in: %SCRIPT_DIR%
    echo.
    echo Please ensure flips.exe is in the same folder as this script.
    echo Download Flips from: https://github.com/Alcaro/Flips/releases
    echo.
    pause
    exit /b 1
)

if not exist "%SCRIPT_DIR%\Patching Layout.csv" (
    echo ERROR: Patching Layout.csv not found in: %SCRIPT_DIR%
    echo.
    pause
    exit /b 1
)

rem Display menu
:Menu
cls
echo ==================== Romset Builder ====================
echo ==================== Using FLIPS (https://github.com/Alcaro/Flips) ====================
echo    Layout: Patching Layout.csv
echo.
echo Please select an option (All of the sets below are supported by HBMAME and MAME2003-plus):
echo.
echo --- Stock Artoria ---
echo   1. Patch gngmaiden      [Ghosts'n Goblins - Maiden Artoria Edition (World? set 1)] **[Supported by FB Neo]**
echo   2. Patch gngknight      [Ghosts'n Goblins - Knight Artoria Edition (World? set 1)] **[Supported by FB Neo]**
echo   3. Patch gngmaidena     [Ghosts'n Goblins - Maiden Artoria Edition (World? set 2)]
echo   4. Patch gngknighta     [Ghosts'n Goblins - Knight Artoria Edition (World? set 2)]
echo   5. Patch gngmaidenb     [Ghosts'n Goblins - Maiden Artoria Edition (World? set 3)]
echo   6. Patch gngknightb     [Ghosts'n Goblins - Knight Artoria Edition (World? set 3)]
echo   7. Patch gngmaidenc     [Ghosts'n Goblins - Maiden Artoria Edition (World? set 4)]
echo   8. Patch gngknightc     [Ghosts'n Goblins - Knight Artoria Edition (World? set 4)]
echo   9. Patch gngmaident     [Ghosts'n Goblins - Maiden Artoria Edition (US)]
echo  10. Patch gngknightt     [Ghosts'n Goblins - Knight Artoria Edition (US)]
echo  11. Patch makmaiden      [Makaimura - Maiden Artoria Edition (Japan)] **[Supported by FB Neo]**
echo  12. Patch makknight      [Makaimura - Knight Artoria Edition (Japan)] **[Supported by FB Neo]**
echo  13. Patch makmaidenb     [Makaimura - Maiden Artoria Edition (Japan revision B)]
echo  14. Patch makknightb     [Makaimura - Knight Artoria Edition (Japan revision B)]
echo  15. Patch makmaidenc     [Makaimura - Maiden Artoria Edition (Japan revision C)]
echo  16. Patch makknightc     [Makaimura - Knight Artoria Edition (Japan revision C)]
echo  17. Patch makmaideng     [Makaimura - Maiden Artoria Edition (Japan revision G)]
echo  18. Patch makknightg     [Makaimura - Knight Artoria Edition (Japan revision G)]
echo.
echo --- Enhanced Artoria (same sources as stock: gng, gnga, ...) ---
echo  19. Patch gngmaidenenh     [Ghosts'n Goblins - Maiden Artoria Edition Enhanced (World? set 1)]
echo  20. Patch gngknightenh     [Ghosts'n Goblins - Knight Artoria Edition Enhanced (World? set 1)]
echo  21. Patch gngmaidenaenh    [Ghosts'n Goblins - Maiden Artoria Edition Enhanced (World? set 2)]
echo  22. Patch gngknightaenh    [Ghosts'n Goblins - Knight Artoria Edition Enhanced (World? set 2)]
echo  23. Patch gngmaidenbenh    [Ghosts'n Goblins - Maiden Artoria Edition Enhanced (World? set 3)]
echo  24. Patch gngknightbenh    [Ghosts'n Goblins - Knight Artoria Edition Enhanced (World? set 3)]
echo  25. Patch gngmaidencenh    [Ghosts'n Goblins - Maiden Artoria Edition Enhanced (World? set 4)]
echo  26. Patch gngknightcenh    [Ghosts'n Goblins - Knight Artoria Edition Enhanced (World? set 4)]
echo  27. Patch gngmaidentenh    [Ghosts'n Goblins - Maiden Artoria Edition Enhanced (US)]
echo  28. Patch gngknighttenh    [Ghosts'n Goblins - Knight Artoria Edition Enhanced (US)]
echo  29. Patch makmaidenenh     [Makaimura - Maiden Artoria Edition Enhanced (Japan)]
echo  30. Patch makknightenh     [Makaimura - Knight Artoria Edition Enhanced (Japan)]
echo  31. Patch makmaidenbenh    [Makaimura - Maiden Artoria Edition Enhanced (Japan revision B)]
echo  32. Patch makknightbenh    [Makaimura - Knight Artoria Edition Enhanced (Japan revision B)]
echo  33. Patch makmaidencenh    [Makaimura - Maiden Artoria Edition Enhanced (Japan revision C)]
echo  34. Patch makknightcenh    [Makaimura - Knight Artoria Edition Enhanced (Japan revision C)]
echo  35. Patch makmaidengenh    [Makaimura - Maiden Artoria Edition Enhanced (Japan revision G)]
echo  36. Patch makknightgenh    [Makaimura - Knight Artoria Edition Enhanced (Japan revision G)]
echo.
echo  37. Patch all stock (18)
echo  38. Patch all Enhanced (18)
echo  39. Patch all (36)
echo  40. Exit
echo.
set /p "choice=Enter your choice (1-40): "

if "%choice%"=="1" ( set "BUILD=gngmaiden" & goto :ChooseOutputFormat )
if "%choice%"=="2" ( set "BUILD=gngknight" & goto :ChooseOutputFormat )
if "%choice%"=="3" ( set "BUILD=gngmaidena" & goto :ChooseOutputFormat )
if "%choice%"=="4" ( set "BUILD=gngknighta" & goto :ChooseOutputFormat )
if "%choice%"=="5" ( set "BUILD=gngmaidenb" & goto :ChooseOutputFormat )
if "%choice%"=="6" ( set "BUILD=gngknightb" & goto :ChooseOutputFormat )
if "%choice%"=="7" ( set "BUILD=gngmaidenc" & goto :ChooseOutputFormat )
if "%choice%"=="8" ( set "BUILD=gngknightc" & goto :ChooseOutputFormat )
if "%choice%"=="9" ( set "BUILD=gngmaident" & goto :ChooseOutputFormat )
if "%choice%"=="10" ( set "BUILD=gngknightt" & goto :ChooseOutputFormat )
if "%choice%"=="11" ( set "BUILD=makmaiden" & goto :ChooseOutputFormat )
if "%choice%"=="12" ( set "BUILD=makknight" & goto :ChooseOutputFormat )
if "%choice%"=="13" ( set "BUILD=makmaidenb" & goto :ChooseOutputFormat )
if "%choice%"=="14" ( set "BUILD=makknightb" & goto :ChooseOutputFormat )
if "%choice%"=="15" ( set "BUILD=makmaidenc" & goto :ChooseOutputFormat )
if "%choice%"=="16" ( set "BUILD=makknightc" & goto :ChooseOutputFormat )
if "%choice%"=="17" ( set "BUILD=makmaideng" & goto :ChooseOutputFormat )
if "%choice%"=="18" ( set "BUILD=makknightg" & goto :ChooseOutputFormat )
if "%choice%"=="19" ( set "BUILD=gngmaidenenh" & goto :ChooseOutputFormat )
if "%choice%"=="20" ( set "BUILD=gngknightenh" & goto :ChooseOutputFormat )
if "%choice%"=="21" ( set "BUILD=gngmaidenaenh" & goto :ChooseOutputFormat )
if "%choice%"=="22" ( set "BUILD=gngknightaenh" & goto :ChooseOutputFormat )
if "%choice%"=="23" ( set "BUILD=gngmaidenbenh" & goto :ChooseOutputFormat )
if "%choice%"=="24" ( set "BUILD=gngknightbenh" & goto :ChooseOutputFormat )
if "%choice%"=="25" ( set "BUILD=gngmaidencenh" & goto :ChooseOutputFormat )
if "%choice%"=="26" ( set "BUILD=gngknightcenh" & goto :ChooseOutputFormat )
if "%choice%"=="27" ( set "BUILD=gngmaidentenh" & goto :ChooseOutputFormat )
if "%choice%"=="28" ( set "BUILD=gngknighttenh" & goto :ChooseOutputFormat )
if "%choice%"=="29" ( set "BUILD=makmaidenenh" & goto :ChooseOutputFormat )
if "%choice%"=="30" ( set "BUILD=makknightenh" & goto :ChooseOutputFormat )
if "%choice%"=="31" ( set "BUILD=makmaidenbenh" & goto :ChooseOutputFormat )
if "%choice%"=="32" ( set "BUILD=makknightbenh" & goto :ChooseOutputFormat )
if "%choice%"=="33" ( set "BUILD=makmaidencenh" & goto :ChooseOutputFormat )
if "%choice%"=="34" ( set "BUILD=makknightcenh" & goto :ChooseOutputFormat )
if "%choice%"=="35" ( set "BUILD=makmaidengenh" & goto :ChooseOutputFormat )
if "%choice%"=="36" ( set "BUILD=makknightgenh" & goto :ChooseOutputFormat )
if "%choice%"=="37" ( set "PATCH_SET=stock" & goto :ChooseOutputFormat )
if "%choice%"=="38" ( set "PATCH_SET=enh" & goto :ChooseOutputFormat )
if "%choice%"=="39" ( set "PATCH_SET=all" & goto :ChooseOutputFormat )
if "%choice%"=="40" ( exit /b 0 )

echo.
echo Invalid choice. Please try again.
echo.
pause
goto :Menu

:ChooseOutputFormat
echo.
echo ROM layout (source and output use the same style):
echo   1. Folders  - read gng\, gnga\, ...  write gngmaiden\ / gngmaidenenh\, ...
echo   2. Zip files - read gng.zip, gnga.zip, ...  write gngmaiden.zip / gngmaidenenh.zip, ...
echo.
set /p "fmt_choice=Enter format choice (1-2): "
if "%fmt_choice%"=="1" (
    set "OUT_MODE=folder"
    if "%choice%"=="37" ( goto :DoPatchStock )
    if "%choice%"=="38" ( goto :DoPatchEnh )
    if "%choice%"=="39" ( goto :DoPatchAll )
    goto :DoPatch
)
if "%fmt_choice%"=="2" (
    set "OUT_MODE=zip"
    if "%choice%"=="37" ( goto :DoPatchStock )
    if "%choice%"=="38" ( goto :DoPatchEnh )
    if "%choice%"=="39" ( goto :DoPatchAll )
    goto :DoPatch
)
echo.
echo Invalid format choice. Please try again.
pause
goto :ChooseOutputFormat

:DoPatch
echo.
echo ==================== PATCHING %BUILD% ====================
echo Output: %OUT_MODE%
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "%BUILD%" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
set "PATCH_ERR=!errorlevel!"
echo.
if !PATCH_ERR! neq 0 (
    echo [WARNING] Patching finished with errors.
) else (
    echo [SUCCESS] Patching completed.
)
echo.
pause
exit /b !PATCH_ERR!

:DoPatchStock
echo.
echo ==================== PATCHING ALL STOCK (18 builds) ====================
echo Output: %OUT_MODE%
set "ANY_ERR=0"
echo.
echo --- 1/18 gngmaiden ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaiden" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 2/18 gngknight ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknight" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 3/18 gngmaidena ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidena" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 4/18 gngknighta ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknighta" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 5/18 gngmaidenb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 6/18 gngknightb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 7/18 gngmaidenc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 8/18 gngknightc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 9/18 gngmaident ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaident" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 10/18 gngknightt ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightt" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 11/18 makmaiden ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaiden" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 12/18 makknight ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknight" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 13/18 makmaidenb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 14/18 makknightb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 15/18 makmaidenc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 16/18 makknightc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 17/18 makmaideng ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaideng" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 18/18 makknightg ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightg" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo ==================== ALL DONE ====================
if !ANY_ERR! neq 0 (
    echo [WARNING] One or more builds had errors.
) else (
    echo [SUCCESS] All 18 builds completed.
)
echo.
pause
exit /b !ANY_ERR!

:DoPatchEnh
echo.
echo ==================== PATCHING ALL ENHANCED (18 builds) ====================
echo Output: %OUT_MODE%
set "ANY_ERR=0"
echo.
echo --- 1/18 gngmaidenenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 2/18 gngknightenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 3/18 gngmaidenaenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenaenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 4/18 gngknightaenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightaenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 5/18 gngmaidenbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 6/18 gngknightbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 7/18 gngmaidencenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidencenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 8/18 gngknightcenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightcenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 9/18 gngmaidentenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidentenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 10/18 gngknighttenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknighttenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 11/18 makmaidenenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 12/18 makknightenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 13/18 makmaidenbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 14/18 makknightbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 15/18 makmaidencenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidencenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 16/18 makknightcenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightcenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 17/18 makmaidengenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidengenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 18/18 makknightgenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightgenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo ==================== ALL DONE ====================
if !ANY_ERR! neq 0 (
    echo [WARNING] One or more builds had errors.
) else (
    echo [SUCCESS] All 18 builds completed.
)
echo.
pause
exit /b !ANY_ERR!

:DoPatchAll
echo.
echo ==================== PATCHING ALL (36 builds) ====================
echo Output: %OUT_MODE%
set "ANY_ERR=0"
echo.
echo --- 1/36 gngmaiden ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaiden" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 2/36 gngknight ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknight" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 3/36 gngmaidena ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidena" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 4/36 gngknighta ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknighta" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 5/36 gngmaidenb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 6/36 gngknightb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 7/36 gngmaidenc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 8/36 gngknightc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 9/36 gngmaident ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaident" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 10/36 gngknightt ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightt" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 11/36 makmaiden ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaiden" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 12/36 makknight ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknight" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 13/36 makmaidenb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 14/36 makknightb ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightb" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 15/36 makmaidenc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 16/36 makknightc ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightc" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 17/36 makmaideng ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaideng" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 18/36 makknightg ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightg" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 19/36 gngmaidenenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 20/36 gngknightenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 21/36 gngmaidenaenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenaenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 22/36 gngknightaenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightaenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 23/36 gngmaidenbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidenbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 24/36 gngknightbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 25/36 gngmaidencenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidencenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 26/36 gngknightcenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknightcenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 27/36 gngmaidentenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngmaidentenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 28/36 gngknighttenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngknighttenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 29/36 makmaidenenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 30/36 makknightenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 31/36 makmaidenbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidenbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 32/36 makknightbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 33/36 makmaidencenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidencenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 34/36 makknightcenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightcenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 35/36 makmaidengenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makmaidengenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 36/36 makknightgenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makknightgenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo ==================== ALL DONE ====================
if !ANY_ERR! neq 0 (
    echo [WARNING] One or more builds had errors.
) else (
    echo [SUCCESS] All 36 builds completed.
)
echo.
pause
exit /b !ANY_ERR!

