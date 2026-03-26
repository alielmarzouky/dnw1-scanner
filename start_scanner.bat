@echo off
title DNW1 Yard Marshall Scanner
color 0A

echo ==========================================
echo    DNW1 - Yard Marshall Scanner Launcher
echo ==========================================
echo.
echo Select your browser:
echo.
echo   [1] Google Chrome
echo   [2] Mozilla Firefox
echo   [3] Microsoft Edge
echo   [4] Open with Default Browser
echo.
set /p choice="Enter number (1-4): "

:: Get the full path to scanner.html
set FILEPATH=%~dp0scanner.html
set FILEURL=file:///%FILEPATH:\=/%

if "%choice%"=="1" goto CHROME
if "%choice%"=="2" goto FIREFOX
if "%choice%"=="3" goto EDGE
if "%choice%"=="4" goto DEFAULT
goto DEFAULT

:CHROME
echo Starting Chrome...
:: Try standard Chrome location
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --app="%FILEURL%" --start-fullscreen --disable-pinch
    goto END
)
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    start "" "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --app="%FILEURL%" --start-fullscreen --disable-pinch
    goto END
)
echo Chrome not found! Opening with default browser...
goto DEFAULT

:FIREFOX
echo Starting Firefox...
:: Try standard Firefox locations
if exist "C:\Program Files\Mozilla Firefox\firefox.exe" (
    start "" "C:\Program Files\Mozilla Firefox\firefox.exe" -kiosk "%FILEURL%"
    goto END
)
if exist "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" (
    start "" "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" -kiosk "%FILEURL%"
    goto END
)
echo Firefox not found! Opening with default browser...
goto DEFAULT

:EDGE
echo Starting Edge...
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --app="%FILEURL%" --start-fullscreen
    goto END
)
echo Edge not found! Opening with default browser...
goto DEFAULT

:DEFAULT
echo Starting default browser...
start "" "%FILEPATH%"
goto END

:END
echo.
echo Scanner started! You can close this window.
timeout /t 3 >nul
exit