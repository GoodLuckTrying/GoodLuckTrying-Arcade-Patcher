@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "WORD=knight"
set "COUNT=0"

for %%F in (*) do (
    if /i not "%%~xF"==".bat" (
        set "BASE=%%~nF"
        set "EXT=%%~xF"
        set "NEWBASE=!BASE:%WORD%=!"
        if not "!NEWBASE!"=="!BASE!" (
            ren "%%F" "!NEWBASE!!EXT!"
            set /a COUNT+=1
        )
    )
)

echo.
echo Removed "%WORD%" from before the extension on %COUNT% file(s).
pause
