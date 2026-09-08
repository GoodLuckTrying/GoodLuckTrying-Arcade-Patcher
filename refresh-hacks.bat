@echo off
cd /d "%~dp0"
echo Refreshing manifests and preview images...
python _tools\generate-manifests.py
if errorlevel 1 (
  echo.
  echo Refresh failed.
  exit /b 1
)
echo.
echo Refresh complete.