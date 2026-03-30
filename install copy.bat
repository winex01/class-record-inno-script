@echo off
setlocal enabledelayedexpansion

set step=1

echo ========================================
echo Setting up Class Record Application
echo ========================================
echo.

echo !step!. Checking Herd status...
set /a step+=1
tasklist /FI "IMAGENAME eq Herd.exe" /NH
echo.

echo !step!. Starting Herd if not running...
set /a step+=1
if not exist "C:\Program Files\Herd\Herd.exe" (
    echo Herd not installed! Installing Herd...
    echo.
    if exist "%~dp0Herd-1.27.0-setup.exe" (
        echo Running Herd installer...
        "%~dp0Herd-1.27.0-setup.exe" /S
        echo Herd installation complete.
        timeout /t 5 /nobreak > nul
    ) else (
        echo ERROR: Herd installer not found!
        echo Please install Herd manually from https://herd.laravel.com
        pause
        exit
    )
)

tasklist /FI "IMAGENAME eq Herd.exe" /NH | find /I "Herd.exe" > nul
if errorlevel 1 (
    echo Starting Herd...
    start "" "C:\Program Files\Herd\Herd.exe"
    timeout /t 5 /nobreak > nul
) else (
    echo Herd is already running.
)
echo.

echo !step!. Parking the parent folder...
set /a step+=1
cd /d "%USERPROFILE%\Documents\Class Record"
echo Adding path to Herd...
echo y | herd park
echo Path added successfully.

echo.
echo !step!. Changing to application directory...
set /a step+=1
echo Current batch file location: %~dp0
cd /d "%~dp0"
echo Now in: %cd%

echo.
echo !step!. Running database migrations... PLEASE WAIT, THIS MAY TAKE A WHILE...
set /a step+=1
cmd /c "php artisan migrate --force --step"

echo.
echo !step!. Launching application...
set /a step+=1
start "" msedge.exe --app=http://class-record-client.test

echo.
echo ========================================
echo Application launched successfully!
echo This window will close in 5 seconds...
echo ========================================
timeout /t 5 /nobreak > nul
exit