@echo off
echo ========================================
echo Setting up Class Record Application
echo ========================================
echo.

echo 1. Checking Herd status...
tasklist /FI "IMAGENAME eq Herd.exe" /NH
echo.

echo 2. Starting Herd if not running...
if not exist "C:\Program Files\Herd\Herd.exe" (
    echo Herd not installed! Installing Herd...
    echo.
    
    :: Find the Herd installer in the current directory
    if exist "%~dp0Herd-1.27.0-setup.exe" (
        echo Running Herd installer...
        "%~dp0Herd-1.27.0-setup.exe" /S
        echo Herd installation complete.
        timeout /t 2 /nobreak > nul
    ) else (
        echo ERROR: Herd installer not found!
        echo Please install Herd manually from https://herd.laravel.com
        pause
        exit
    )
)

:: Now check again after installation or if already installed
tasklist /FI "IMAGENAME eq Herd.exe" /NH | find /I "Herd.exe" > nul
if errorlevel 1 (
    echo Starting Herd...
    start "" "C:\Program Files\Herd\Herd.exe"
    timeout /t 3 /nobreak > nul
) else (
    echo Herd is already running.
)
echo.

echo 3. Parking the parent folder...
cd /d "%USERPROFILE%\Documents\Class Record"
echo Adding path to Herd...
echo y | herd park > nul 2>&1
echo Path added successfully.
timeout /t 1 /nobreak > nul
echo.

echo 4. Changing to application directory...
echo Current batch file location: %~dp0
cd /d "%~dp0"
echo Now in: %cd%
echo.

echo 5. Running database migrations...
echo Running migrations...
cmd /c "php artisan migrate --force --step"
echo.

echo 6. Clearing caches...
cmd /c "php artisan optimize:clear"
echo.

echo 7. Building frontend assets...
cmd /c "npm run build < nul"
echo.

echo 8. Optimizing application...
cmd /c "php artisan optimize"
echo.

echo 9. Launching application...
start wscript.exe "launch.vbs"
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo Reached the end! Closing in 5 seconds...
timeout /t 5 /nobreak > nul
exit /b 0