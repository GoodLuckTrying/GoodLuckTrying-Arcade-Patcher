@echo off
cd /d "%~dp0"
echo Starting web server at http://localhost:8080/
echo Press Ctrl+C to stop.
start "" "http://localhost:8080/"
python -m http.server 8080
