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
:: Check and Start Herd
:: ----------------------------------------
echo Checking Herd status...
tasklist /FI "IMAGENAME eq Herd.exe" /NH
echo.

echo Starting Herd if not running...
if not exist "C:\Program Files\Herd\Herd.exe" (
    echo Herd not installed! Installing Herd...
    echo.

    :: Find the Herd installer in the current directory
    if exist "%~dp0Herd-1.27.0-setup.exe" (
        echo Running Herd installer...
        echo Please wait, this may take a while depending on your system...
        "%~dp0Herd-1.27.0-setup.exe" /S
        echo Herd installation complete.
        timeout /t 3 /nobreak > nul

        :: Add Herd to PATH for this session
        set "PATH=%PATH%;C:\Program Files\Herd\bin"
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
    powershell -Command "Start-Process 'C:\Program Files\Herd\Herd.exe' -WindowStyle Hidden"
    timeout /t 5 /nobreak > nul

    :: Wait for Herd to fully initialize
    echo Waiting for Herd to initialize...
    timeout /t 3 /nobreak > nul
) else (
    echo Herd is already running.
)
echo.

:: ----------------------------------------
:: Park the parent folder in Herd
:: ----------------------------------------
echo Parking the parent folder...
cd /d "%USERPROFILE%\Documents\Class Record"

:: Use full path to herd if available, otherwise try the command
if exist "C:\Program Files\Herd\bin\herd.exe" (
    echo Adding path to Herd using full path...
    echo y | "C:\Program Files\Herd\bin\herd.exe" park > nul 2>&1
) else (
    echo Adding path to Herd...
    echo y | herd park > nul 2>&1
)
echo Path added successfully.
timeout /t 1 /nobreak > nul
echo.

:: ----------------------------------------
:: Change to application directory
:: ----------------------------------------
echo Changing to application directory...
echo Current batch file location: %~dp0
cd /d "%~dp0"
echo Now in: %cd%
echo.

:: ----------------------------------------
:: Install PHP dependencies
:: ----------------------------------------
echo [1/10] Installing PHP dependencies...
echo Please wait, this may take a while depending on your system...
cmd /c "composer install"
echo.

:: ----------------------------------------
:: Copy environment file
:: ----------------------------------------
echo [2/10] Copying environment file...
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
echo [3/10] Generating application key...
cmd /c "php artisan key:generate"
echo.

:: ----------------------------------------
:: Install Node dependencies
:: ----------------------------------------
echo [4/10] Installing Node dependencies...
echo Please wait, this may take a while depending on your system...
cmd /c "npm install"
echo.

:: ----------------------------------------
:: Fix vulnerabilities
:: ----------------------------------------
echo [5/10] Fixing known vulnerabilities...
cmd /c "npm audit fix"
echo.

:: ----------------------------------------
:: Build frontend assets
:: ----------------------------------------
echo [6/10] Building frontend assets...
echo Please wait, this may take a while depending on your system...
cmd /c "npm run build"
echo.

:: ----------------------------------------
:: Run database migrations
:: ----------------------------------------
echo [7/10] Running database migrations...
echo Please wait, this may take a while depending on your system...
cmd /c "php artisan migrate --force --step"
echo.

:: ----------------------------------------
:: Seed the database
:: ----------------------------------------
echo [8/10] Seeding the database...
cmd /c "php artisan db:seed --force"
echo.

:: ----------------------------------------
:: Link storage
:: ----------------------------------------
echo [9/10] Linking storage...
cmd /c "php artisan storage:link"
echo.

:: ----------------------------------------
:: Cache and optimize
:: ----------------------------------------
echo [10/10] Clearing and optimizing the application...
cmd /c "php artisan optimize:clear"
cmd /c "php artisan filament:optimize"
cmd /c "php artisan config:cache"
cmd /c "php artisan route:cache"
cmd /c "php artisan event:cache"
cmd /c "php artisan view:cache"
echo.

:: ----------------------------------------
:: DONE
:: ----------------------------------------
echo ========================================
echo  Setup Complete!
echo ========================================
echo  Your Class Record application is ready.
echo  Closing in 5 seconds...
echo.
echo  If the window doesn't close automatically,
echo  you can close it manually.
timeout /t 5 /nobreak > nul

exit