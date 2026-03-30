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
echo !step!. Updating .env for production...
set /a step+=1

set "ENV_FILE=%~dp0.env"
set "TEMP_FILE=%~dp0.env.tmp"

if exist "!ENV_FILE!" (
    break > "!TEMP_FILE!"
    for /f "usebackq delims=" %%A in ("!ENV_FILE!") do (
        set "line=%%A"
        if "!line:~0,8!"=="APP_URL=" set "line=APP_URL=http://class-record-client.test"
        if "!line:~0,8!"=="APP_ENV=" set "line=APP_ENV=production"
        if "!line:~0,10!"=="APP_DEBUG=" set "line=APP_DEBUG=false"
        if "!line:~0,18!"=="DEBUGBAR_ENABLED=" set "line=DEBUGBAR_ENABLED=false"
        if "!line:~0,18!"=="TELESCOPE_ENABLED=" set "line=TELESCOPE_ENABLED=false"
        echo(!line!>>"!TEMP_FILE!"
    )
    move /Y "!TEMP_FILE!" "!ENV_FILE!" > nul
    echo OK
) else (
    echo WARNING: .env file not found! Skipping update.
)

echo.
echo !step!. Running database migrations... PLEASE WAIT, THIS MAY TAKE A WHILE...
set /a step+=1
cmd /c "php artisan migrate --force --step"

echo.
echo !step!. Launching application...
set /a step+=1
start wscript.exe "launch.vbs"
timeout /t 2 /nobreak > nul

echo.
exit /b 0