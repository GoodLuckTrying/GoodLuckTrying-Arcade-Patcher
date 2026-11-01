@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
if not exist "%SCRIPT_DIR%\flips.exe" (
    echo ERROR: flips.exe is missing from "%SCRIPT_DIR%"
    pause
    exit /b 1
)
if not exist "%SCRIPT_DIR%\Patching Layout.csv" (
    echo ERROR: Patching Layout.csv is missing from "%SCRIPT_DIR%"
    pause
    exit /b 1
)

:Menu
cls
echo ==================== Princess Edition ROM Patcher ====================
echo.
echo --- Stock Princess ---
echo  1. Patch gngprincess     [Ghosts'n Goblins - Princess Prin Prin Edition (World set 1)]
echo  2. Patch gngprincessa    [Ghosts'n Goblins - Princess Prin Prin Edition (World set 2)]
echo  3. Patch gngprincessb    [Ghosts'n Goblins - Princess Prin Prin Edition (World set 3)]
echo  4. Patch gngprincessc    [Ghosts'n Goblins - Princess Prin Prin Edition (World set 4)]
echo  5. Patch gngprincesst    [Ghosts'n Goblins - Princess Prin Prin Edition (US)]
echo  6. Patch makprincess     [Makaimura - Princess Prin Prin Edition (Japan)]
echo  7. Patch makprincessb    [Makaimura - Princess Prin Prin Edition (Japan revision B)]
echo  8. Patch makprincessc    [Makaimura - Princess Prin Prin Edition (Japan revision C)]
echo  9. Patch makprincessg    [Makaimura - Princess Prin Prin Edition (Japan revision G)]
echo.
echo --- Enhanced Princess (same clean ROM sources as stock) ---
echo 10. Patch gngprincessenh   [Ghosts'n Goblins - Princess Prin Prin Edition Enhanced (World set 1)]
echo 11. Patch gngprincessaenh  [Ghosts'n Goblins - Princess Prin Prin Edition Enhanced (World set 2)]
echo 12. Patch gngprincessbenh  [Ghosts'n Goblins - Princess Prin Prin Edition Enhanced (World set 3)]
echo 13. Patch gngprincesscenh  [Ghosts'n Goblins - Princess Prin Prin Edition Enhanced (World set 4)]
echo 14. Patch gngprincesstenh  [Ghosts'n Goblins - Princess Prin Prin Edition Enhanced (US)]
echo 15. Patch makprincessenh   [Makaimura - Princess Prin Prin Edition Enhanced (Japan)]
echo 16. Patch makprincessbenh  [Makaimura - Princess Prin Prin Edition Enhanced (Japan revision B)]
echo 17. Patch makprincesscenh  [Makaimura - Princess Prin Prin Edition Enhanced (Japan revision C)]
echo 18. Patch makprincessgenh  [Makaimura - Princess Prin Prin Edition Enhanced (Japan revision G)]
echo.
echo 19. Patch all stock (9)
echo 20. Patch all Enhanced (9)
echo 21. Patch all (18)
echo 22. Exit
echo.
set /p "CHOICE=Select an edition or group (1-22): "

set "BUILD="
set "BUILDS="
if "%CHOICE%"=="1" set "BUILD=gngprincess"
if "%CHOICE%"=="2" set "BUILD=gngprincessa"
if "%CHOICE%"=="3" set "BUILD=gngprincessb"
if "%CHOICE%"=="4" set "BUILD=gngprincessc"
if "%CHOICE%"=="5" set "BUILD=gngprincesst"
if "%CHOICE%"=="6" set "BUILD=makprincess"
if "%CHOICE%"=="7" set "BUILD=makprincessb"
if "%CHOICE%"=="8" set "BUILD=makprincessc"
if "%CHOICE%"=="9" set "BUILD=makprincessg"
if "%CHOICE%"=="10" set "BUILD=gngprincessenh"
if "%CHOICE%"=="11" set "BUILD=gngprincessaenh"
if "%CHOICE%"=="12" set "BUILD=gngprincessbenh"
if "%CHOICE%"=="13" set "BUILD=gngprincesscenh"
if "%CHOICE%"=="14" set "BUILD=gngprincesstenh"
if "%CHOICE%"=="15" set "BUILD=makprincessenh"
if "%CHOICE%"=="16" set "BUILD=makprincessbenh"
if "%CHOICE%"=="17" set "BUILD=makprincesscenh"
if "%CHOICE%"=="18" set "BUILD=makprincessgenh"
if "%CHOICE%"=="19" set "BUILDS=gngprincess gngprincessa gngprincessb gngprincessc gngprincesst makprincess makprincessb makprincessc makprincessg"
if "%CHOICE%"=="20" set "BUILDS=gngprincessenh gngprincessaenh gngprincessbenh gngprincesscenh gngprincesstenh makprincessenh makprincessbenh makprincesscenh makprincessgenh"
if "%CHOICE%"=="21" set "BUILDS=gngprincess gngprincessa gngprincessb gngprincessc gngprincesst makprincess makprincessb makprincessc makprincessg gngprincessenh gngprincessaenh gngprincessbenh gngprincesscenh gngprincesstenh makprincessenh makprincessbenh makprincesscenh makprincessgenh"
if "%CHOICE%"=="22" exit /b 0
if not defined BUILD if not defined BUILDS (
    echo Invalid selection.
    pause
    goto :Menu
)

echo.
echo Output format:
echo  1. ROM folders
echo  2. ZIP archives
set /p "FORMAT=Select format (1-2): "
if "%FORMAT%"=="1" set "OUTPUT_MODE=folder"
if "%FORMAT%"=="2" set "OUTPUT_MODE=zip"
if not defined OUTPUT_MODE (
    echo Invalid format.
    pause
    goto :Menu
)

set "FAILED=0"
if defined BUILD call :RunBuild "%BUILD%"
if defined BUILDS for %%B in (%BUILDS%) do call :RunBuild %%B
set "OUTPUT_MODE="

echo.
if "%FAILED%"=="0" (
    echo All selected builds completed.
) else (
    echo One or more builds failed. See the error messages above.
)
pause
exit /b %FAILED%

:RunBuild
echo.
echo Building %~1...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "%~1" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUTPUT_MODE%"
if errorlevel 1 set "FAILED=1"
exit /b 0
