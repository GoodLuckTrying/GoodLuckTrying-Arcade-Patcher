@echo off
setlocal enabledelayedexpansion

rem cd first so paths with () do not break if () blocks.
rem Use %~dp0. (not %~dp0) so a trailing \ does not escape the closing quote.
cd /d "%~dp0." || exit /b 1
set "SCRIPT_DIR=%CD%"

echo ==================== FLIPS ROM PATCHER ====================
echo    Layout: Patching Layout.csv
echo.

if not exist "flips.exe" goto :ErrNoFlips
if not exist "Patching Layout.csv" goto :ErrNoCsv
goto :Menu

:ErrNoFlips
echo ERROR: flips.exe not found in:
echo   %SCRIPT_DIR%
echo.
echo Please ensure flips.exe is in the same folder as this script.
echo Download Flips from: https://github.com/Alcaro/Flips/releases
echo.
pause
exit /b 1

:ErrNoCsv
echo ERROR: Patching Layout.csv not found in:
echo   %SCRIPT_DIR%
echo.
pause
exit /b 1

:Menu
cls
echo ==================== Romset Builder ====================
echo ==================== Using FLIPS [https://github.com/Alcaro/Flips] ====================
echo    Layout: Patching Layout.csv
echo.
echo Please select an option:
echo.
echo   1. Patch ghoulsmaiden    [Ghouls'n Ghosts - Maiden Artoria Edition (Worl)]
echo   2. Patch ghoulsknight    [Ghouls'n Ghosts - Knight Artoria Edition (World)]
echo   3. Patch ghoulsumaiden   [Ghouls'n Ghosts - Maiden Artoria Edition (USA)]
echo   4. Patch ghoulsuknight   [Ghouls'n Ghosts - Knight Artoria Edition (USA)]
echo   5. Patch daimakaimaiden  [Daimakaimura - Maiden Artoria Edition (Japan)]
echo   6. Patch daimakaiknight  [Daimakaimura - Knight Artoria Edition (Japan)]
echo   7. Patch all
echo   8. Exit
echo.
set /p "choice=Enter your choice [1-8]: "

if "%choice%"=="1" set "BUILD=ghoulsmaiden" & goto :ChooseOutputFormat
if "%choice%"=="2" set "BUILD=ghoulsknight" & goto :ChooseOutputFormat
if "%choice%"=="3" set "BUILD=ghoulsumaiden" & goto :ChooseOutputFormat
if "%choice%"=="4" set "BUILD=ghoulsuknight" & goto :ChooseOutputFormat
if "%choice%"=="5" set "BUILD=daimakaimaiden" & goto :ChooseOutputFormat
if "%choice%"=="6" set "BUILD=daimakaiknight" & goto :ChooseOutputFormat
if "%choice%"=="7" goto :ChooseOutputFormat
if "%choice%"=="8" exit /b 0

echo.
echo Invalid choice. Please try again.
echo.
pause
goto :Menu

:ChooseOutputFormat
echo.
echo ROM layout [source and output use the same style]:
echo   1. Folders   - read ghouls\ / ghoulsu\ / daimakai\
echo                  write ghoulsmaiden\ / ghoulsknight\ / ghoulsumaiden\ / ghoulsuknight\ /
echo                         daimakaimaiden\ / daimakaiknight\
echo   2. Zip files - read ghouls.zip / ghoulsu.zip / daimakai.zip
echo                  write matching .zip outputs
echo.
set /p "fmt_choice=Enter format choice [1-2]: "
if "%fmt_choice%"=="1" goto :FormatFolder
if "%fmt_choice%"=="2" goto :FormatZip
echo.
echo Invalid format choice. Please try again.
pause
goto :ChooseOutputFormat

:FormatFolder
set "OUT_MODE=folder"
if "%choice%"=="7" goto :DoPatchAll
goto :DoPatch

:FormatZip
set "OUT_MODE=zip"
if "%choice%"=="7" goto :DoPatchAll
goto :DoPatch

:DoPatch
echo.
echo ==================== PATCHING %BUILD% ====================
echo Output: %OUT_MODE%
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Apply-PatchLayout.ps1" -BuildType "%BUILD%" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
set "PATCH_ERR=!errorlevel!"
echo.
if not "!PATCH_ERR!"=="0" (
    echo [WARNING] Patching finished with errors.
) else (
    echo [SUCCESS] Patching completed.
)
echo.
pause
exit /b !PATCH_ERR!

:DoPatchAll
echo.
echo ==================== PATCHING ALL [6 builds] ====================
echo Output: %OUT_MODE%
set "ANY_ERR=0"
echo.
echo --- 1/6 ghoulsmaiden [World] ---
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Apply-PatchLayout.ps1" -BuildType "ghoulsmaiden" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if not "!errorlevel!"=="0" set "ANY_ERR=1"
echo.
echo --- 2/6 ghoulsknight [World] ---
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Apply-PatchLayout.ps1" -BuildType "ghoulsknight" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if not "!errorlevel!"=="0" set "ANY_ERR=1"
echo.
echo --- 3/6 ghoulsumaiden [USA] ---
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Apply-PatchLayout.ps1" -BuildType "ghoulsumaiden" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if not "!errorlevel!"=="0" set "ANY_ERR=1"
echo.
echo --- 4/6 ghoulsuknight [USA] ---
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Apply-PatchLayout.ps1" -BuildType "ghoulsuknight" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if not "!errorlevel!"=="0" set "ANY_ERR=1"
echo.
echo --- 5/6 daimakaimaiden [Japan] ---
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Apply-PatchLayout.ps1" -BuildType "daimakaimaiden" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if not "!errorlevel!"=="0" set "ANY_ERR=1"
echo.
echo --- 6/6 daimakaiknight [Japan] ---
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Apply-PatchLayout.ps1" -BuildType "daimakaiknight" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if not "!errorlevel!"=="0" set "ANY_ERR=1"
echo.
echo ==================== ALL DONE ====================
if not "!ANY_ERR!"=="0" (
    echo [WARNING] One or more builds had errors.
) else (
    echo [SUCCESS] All builds completed.
)
echo.
pause
exit /b !ANY_ERR!
