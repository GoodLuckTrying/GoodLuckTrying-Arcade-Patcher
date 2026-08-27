@echo off
setlocal enabledelayedexpansion

echo ==================== FLIPS ROM PATCHER ====================
echo    Enhanced Hacks (vanilla + control ROM patches)
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
echo    Enhanced Hacks (vanilla + control ROM patches)
echo    Layout: Patching Layout.csv
echo.
echo Please select an option:
echo.
echo   1. Patch gngenh        [Ghosts'n Goblins (Enhanced) (World? set 1)] **[Supported by FB Neo]**
echo   2. Patch gngaenh       [Ghosts'n Goblins (Enhanced) (World? set 2)]
echo   3. Patch gngbenh       [Ghosts'n Goblins (Enhanced) (World? set 3)]
echo   4. Patch gngcenh       [Ghosts'n Goblins (Enhanced) (World? set 4)]
echo   5. Patch gngtenh       [Ghosts'n Goblins (Enhanced) (US)]
echo   6. Patch makaimurenh   [Makaimura (Enhanced) (Japan revision A?)] **[Supported by FB Neo]**
echo   7. Patch makaimurbenh  [Makaimura (Enhanced) (Japan revision B)]
echo   8. Patch makaimurcenh  [Makaimura (Enhanced) (Japan revision C)]
echo   9. Patch makaimurgenh  [Makaimura (Enhanced) (Japan revision G)]
echo.
echo  10. Patch all (9)
echo  11. Exit
echo.
set /p "choice=Enter your choice (1-11): "

if "%choice%"=="1" ( set "BUILD=gngenh" & goto :ChooseOutputFormat )
if "%choice%"=="2" ( set "BUILD=gngaenh" & goto :ChooseOutputFormat )
if "%choice%"=="3" ( set "BUILD=gngbenh" & goto :ChooseOutputFormat )
if "%choice%"=="4" ( set "BUILD=gngcenh" & goto :ChooseOutputFormat )
if "%choice%"=="5" ( set "BUILD=gngtenh" & goto :ChooseOutputFormat )
if "%choice%"=="6" ( set "BUILD=makaimurenh" & goto :ChooseOutputFormat )
if "%choice%"=="7" ( set "BUILD=makaimurbenh" & goto :ChooseOutputFormat )
if "%choice%"=="8" ( set "BUILD=makaimurcenh" & goto :ChooseOutputFormat )
if "%choice%"=="9" ( set "BUILD=makaimurgenh" & goto :ChooseOutputFormat )
if "%choice%"=="10" ( goto :ChooseOutputFormat )
if "%choice%"=="11" ( exit /b 0 )

echo.
echo Invalid choice. Please try again.
echo.
pause
goto :Menu

:ChooseOutputFormat
echo.
echo ROM layout (source and output use the same style):
echo   1. Folders  - read gng\, gnga\, ...  write gngenh\, gngaenh\, ...
echo   2. Zip files - read gng.zip, gnga.zip, ...  write gngenh.zip, ...
echo.
set /p "fmt_choice=Enter format choice (1-2): "
if "%fmt_choice%"=="1" (
    set "OUT_MODE=folder"
    if "%choice%"=="10" ( goto :DoPatchAll )
    goto :DoPatch
)
if "%fmt_choice%"=="2" (
    set "OUT_MODE=zip"
    if "%choice%"=="10" ( goto :DoPatchAll )
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

:DoPatchAll
echo.
echo ==================== PATCHING ALL ENHANCED (9 builds) ====================
echo Output: %OUT_MODE%
set "ANY_ERR=0"
echo.
echo --- 1/9 gngenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 2/9 gngaenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngaenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 3/9 gngbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 4/9 gngcenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngcenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 5/9 gngtenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "gngtenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 6/9 makaimurenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makaimurenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 7/9 makaimurbenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makaimurbenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 8/9 makaimurcenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makaimurcenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo --- 9/9 makaimurgenh ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\Apply-PatchLayout.ps1" -BuildType "makaimurgenh" -ScriptDir "%SCRIPT_DIR%" -OutputMode "%OUT_MODE%"
if !errorlevel! neq 0 set "ANY_ERR=1"
echo.
echo ==================== ALL DONE ====================
if !ANY_ERR! neq 0 (
    echo [WARNING] One or more builds had errors.
) else (
    echo [SUCCESS] All 9 builds completed.
)
echo.
pause
exit /b !ANY_ERR!
