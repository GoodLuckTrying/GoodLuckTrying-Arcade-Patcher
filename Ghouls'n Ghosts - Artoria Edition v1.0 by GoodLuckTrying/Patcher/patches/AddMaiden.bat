@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "WORD=maiden"
set "SUFFIX=%WORD%"
set "COUNT=0"

for %%F in (*) do (
    if /i not "%%~xF"==".bat" (
        set "BASE=%%~nF"
        set "EXT=%%~xF"
        echo !BASE! | findstr /e /i /c:"%SUFFIX%" >nul
        if errorlevel 1 (
            ren "%%F" "!BASE!%SUFFIX%!EXT!"
            set /a COUNT+=1
        )
    )
)

echo.
echo Added "%WORD%" before the extension on %COUNT% file(s).
pause
