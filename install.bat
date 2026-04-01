@echo off
title Class Record Setup
echo ========================================
echo  Setting up Class Record Application
echo ========================================
echo.

:: ----------------------------------------
:: Add Windows Security Exclusion
:: ----------------------------------------
echo Adding Windows Security exclusion for this folder...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%~dp0'"
echo Exclusion added for: %~dp0
echo.

:: ----------------------------------------
:: Start Herd if not running
:: ----------------------------------------
echo Checking Herd status...
tasklist /FI "IMAGENAME eq Herd.exe" /NH
echo.

echo Starting Herd if not running...
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
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process 'C:\Program Files\Herd\Herd.exe' -WindowStyle Hidden"
    timeout /t 5 /nobreak > nul
) else (
    echo Herd is already running.
)
echo.

:: ----------------------------------------
:: Add Herd PHP to PATH
:: ----------------------------------------
echo Adding Herd PHP to PATH...
set "PATH=%USERPROFILE%\.config\herd\bin;%PATH%"
echo.

:: ----------------------------------------
:: Change to application directory
:: ----------------------------------------
echo Changing to application directory...
cd /d "%~dp0"
echo Now in: %cd%
echo.

:: ----------------------------------------
:: Copy environment file
:: ----------------------------------------
echo Copying environment file...
if not exist ".env" (
    cmd /c "copy .env.example .env"
    echo Environment file created.
) else (
    echo .env already exists, skipping copy.
)
echo.

:: ----------------------------------------
:: Generate application key
:: ----------------------------------------
echo Generating application key...
findstr /r "APP_KEY=.\+" .env > nul 2>&1
if errorlevel 1 (
    cmd /c "php artisan key:generate"
) else (
    echo App key already set, skipping.
)
echo.

:: ----------------------------------------
:: Run database migrations
:: ----------------------------------------
echo Running database migrations...
cmd /c "php artisan migrate --force --step"
echo.

:: ----------------------------------------
:: Cache and optimize
:: ----------------------------------------
echo Clearing and optimizing the application...
cmd /c "php artisan optimize:clear"
cmd /c "php artisan filament:optimize"
cmd /c "php artisan config:cache"
cmd /c "php artisan route:cache"
cmd /c "php artisan event:cache"
cmd /c "php artisan view:cache"
echo.

:: ----------------------------------------
:: Link storage
:: ----------------------------------------
echo Linking storage...
cmd /c "php artisan storage:link"
echo.

:: ----------------------------------------
:: DONE
:: ----------------------------------------
echo ========================================
echo  Setup Complete!
echo ========================================
echo  Your Class Record application is ready.
echo  Closing in 5 seconds...
echo  If this window does not close, you may close it manually.
echo.
timeout /t 5 /nobreak > nul
exit