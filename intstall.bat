@echo off
title DNW1 Installer
color 0A

echo.
echo  ========================================
echo    DNW1 SCANNER INSTALLER
echo    Auto-Update Version
echo  ========================================
echo.

pause

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Right-click and "Run as Administrator"!
    echo.
    pause
    exit /b 1
)

echo  [OK] Admin rights confirmed
echo.

set "APP_URL=https://alielmarzouky.github.io/dnw1-scanner/"
set "APP=C:\DNW1-Scanner"
set "DESK=C:\Users\Public\Desktop"
set "STARTM=C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
set "STARTU=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"

echo  Step 1: Finding browser...

set "BR="
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "BR=C:\Program Files\Google\Chrome\Application\chrome.exe"
    echo  [OK] Found Chrome
    goto FOUND
)
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "BR=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    echo  [OK] Found Chrome x86
    goto FOUND
)
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    set "BR=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    echo  [OK] Found Edge
    goto FOUND
)
if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" (
    set "BR=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    echo  [OK] Found Edge
    goto FOUND
)

echo  ERROR: No browser found!
pause
exit /b 1

:FOUND
echo.
echo  Step 2: Creating app folder...

if not exist "%APP%" mkdir "%APP%"

:: Copy icons if available on USB/shared folder
if exist "%~dp0icon-192.png" copy "%~dp0icon-192.png" "%APP%\" /Y >nul
if exist "%~dp0icon-512.png" copy "%~dp0icon-512.png" "%APP%\" /Y >nul

echo  Step 3: Downloading icon...

:: Try to download icon from GitHub
powershell -NoProfile -Command "try{(New-Object Net.WebClient).DownloadFile('%APP_URL%icon-192.png','C:\DNW1-Scanner\icon-192.png');Write-Host '  [OK] Icon downloaded'}catch{Write-Host '  [SKIP] Using local icon'}"

echo  Step 4: Creating ICO file...

powershell -NoProfile -Command "try{Add-Type -AssemblyName System.Drawing;$i=[System.Drawing.Image]::FromFile('C:\DNW1-Scanner\icon-192.png');$b=New-Object System.Drawing.Bitmap($i,256,256);$c=[System.Drawing.Icon]::FromHandle($b.GetHicon());$f=[System.IO.File]::Create('C:\DNW1-Scanner\app.ico');$c.Save($f);$f.Close();Write-Host '  [OK] Icon created'}catch{Write-Host '  [SKIP] Icon failed'}"

echo.
echo  Step 5: Creating desktop shortcut...

:: Delete old shortcuts
del /f "%DESK%\DNW1 Scanner.lnk" >nul 2>nul

echo Set o = WScript.CreateObject("WScript.Shell") > "%TEMP%\mk.vbs"
echo Set l = o.CreateShortcut("%DESK%\DNW1 Scanner.lnk") >> "%TEMP%\mk.vbs"
echo l.TargetPath = "%BR%" >> "%TEMP%\mk.vbs"
echo l.Arguments = "--app=%APP_URL% --start-maximized --no-first-run --disable-features=TranslateUI" >> "%TEMP%\mk.vbs"
echo l.WorkingDirectory = "C:\DNW1-Scanner" >> "%TEMP%\mk.vbs"
echo l.Description = "DNW1 Yard Marshall Scanner" >> "%TEMP%\mk.vbs"
if exist "%APP%\app.ico" (
echo l.IconLocation = "C:\DNW1-Scanner\app.ico" >> "%TEMP%\mk.vbs"
) else (
echo l.IconLocation = "%BR%,0" >> "%TEMP%\mk.vbs"
)
echo l.Save >> "%TEMP%\mk.vbs"

cscript //nologo "%TEMP%\mk.vbs"
del "%TEMP%\mk.vbs"

echo  [OK] Desktop shortcut created
echo.

echo  Step 5b: Copying to all user desktops...

for /d %%U in (C:\Users\*) do (
    if exist "%%U\Desktop" (
        if /i not "%%U"=="C:\Users\Public" (
        if /i not "%%U"=="C:\Users\Default" (
        if /i not "%%U"=="C:\Users\Default User" (
        if /i not "%%U"=="C:\Users\All Users" (
            copy "%DESK%\DNW1 Scanner.lnk" "%%U\Desktop\" /Y >nul 2>nul
            if not errorlevel 1 echo  [OK] %%~nxU
        ))))
    )
)

echo.
echo  Step 6: Start Menu shortcut...

echo Set o = WScript.CreateObject("WScript.Shell") > "%TEMP%\mk2.vbs"
echo Set l = o.CreateShortcut("%STARTM%\DNW1 Scanner.lnk") >> "%TEMP%\mk2.vbs"
echo l.TargetPath = "%BR%" >> "%TEMP%\mk2.vbs"
echo l.Arguments = "--app=%APP_URL% --start-maximized --no-first-run --disable-features=TranslateUI" >> "%TEMP%\mk2.vbs"
echo l.WorkingDirectory = "C:\DNW1-Scanner" >> "%TEMP%\mk2.vbs"
echo l.Description = "DNW1 Yard Marshall Scanner" >> "%TEMP%\mk2.vbs"
if exist "%APP%\app.ico" (
echo l.IconLocation = "C:\DNW1-Scanner\app.ico" >> "%TEMP%\mk2.vbs"
) else (
echo l.IconLocation = "%BR%,0" >> "%TEMP%\mk2.vbs"
)
echo l.Save >> "%TEMP%\mk2.vbs"

cscript //nologo "%TEMP%\mk2.vbs"
del "%TEMP%\mk2.vbs"

echo  [OK] Start Menu created
echo.

echo  Step 7: Auto-start on login?
set /p AUTO="  Open automatically when Windows starts? (Y/N): "

if /i "%AUTO%"=="Y" (
    echo Set o = WScript.CreateObject("WScript.Shell") > "%TEMP%\mk3.vbs"
    echo Set l = o.CreateShortcut("%STARTU%\DNW1 Scanner.lnk") >> "%TEMP%\mk3.vbs"
    echo l.TargetPath = "%BR%" >> "%TEMP%\mk3.vbs"
    echo l.Arguments = "--app=%APP_URL% --start-maximized --no-first-run --disable-features=TranslateUI" >> "%TEMP%\mk3.vbs"
    echo l.WorkingDirectory = "C:\DNW1-Scanner" >> "%TEMP%\mk3.vbs"
    echo l.Description = "DNW1 Yard Marshall Scanner" >> "%TEMP%\mk3.vbs"
    if exist "%APP%\app.ico" (
    echo l.IconLocation = "C:\DNW1-Scanner\app.ico" >> "%TEMP%\mk3.vbs"
    ) else (
    echo l.IconLocation = "%BR%,0" >> "%TEMP%\mk3.vbs"
    )
    echo l.Save >> "%TEMP%\mk3.vbs"
    cscript //nologo "%TEMP%\mk3.vbs"
    del "%TEMP%\mk3.vbs"
    echo  [OK] Auto-start enabled
) else (
    echo  [SKIP] Auto-start skipped
)

echo.
echo  Step 8: Clearing icon cache...

taskkill /f /im explorer.exe >nul 2>nul
timeout /t 2 /nobreak >nul
del /f /q "%LOCALAPPDATA%\IconCache.db" >nul 2>nul
del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache*" >nul 2>nul
start explorer.exe
timeout /t 2 /nobreak >nul

echo.
echo  ==========================================
echo   INSTALLATION COMPLETE!
echo  ==========================================
echo.
echo   App: DNW1 Yard Marshall Scanner
echo   URL: %APP_URL%
echo.
echo   Desktop shortcut: YES
echo   Start Menu:       YES
echo   Auto-updates:     YES (automatic!)
echo.
echo   When you open the app:
echo   - Looks like a normal app (no browser bar)
echo   - Updates automatically when code changes
echo   - Works offline too
echo.

set /p LAUNCH="  Launch scanner now? (Y/N): "
if /i "%LAUNCH%"=="Y" (
    echo  Starting...
    start "" "%BR%" --app=%APP_URL% --start-maximized --no-first-run --disable-features=TranslateUI
)

echo.
echo  Done!
pause