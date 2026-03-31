@echo off
title Laravel + Filament Project Setup
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
tasklist /FI "IMAGENAME eq Herd.exe" /NH | find /I "Herd.exe" > nul
if errorlevel 1 (
    echo Starting Herd...
    powershell -Command "Start-Process 'C:\Program Files\Herd\Herd.exe' -WindowStyle Hidden"
    echo Waiting for Herd to initialize...
    timeout /t 8 /nobreak > nul
) else (
    echo Herd is already running.
)
echo.

:: ----------------------------------------
:: Park the parent folder in Herd
:: ----------------------------------------
echo Parking the parent folder...
cd /d "%USERPROFILE%\Documents\Class Record"

if exist "C:\Program Files\Herd\bin\herd.exe" (
    echo y | "C:\Program Files\Herd\bin\herd.exe" park > nul 2>&1
) else (
    echo y | herd park > nul 2>&1
)
echo Path added successfully.
timeout /t 1 /nobreak > nul
echo.

:: ----------------------------------------
:: Change to application directory
:: ----------------------------------------
echo Changing to application directory...
cd /d "%~dp0"
echo Now in: %cd%
echo.

:: ----------------------------------------
:: Install PHP dependencies
:: ----------------------------------------
echo Installing PHP dependencies...
echo Please wait, this may take a while depending on your system...
cmd /c "composer install"
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
:: Seed the database
:: ----------------------------------------
echo Seeding the database...
cmd /c "php artisan db:seed --force"
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