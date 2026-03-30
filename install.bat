@echo off
echo ========================================
echo Setting up Class Record Application
echo ========================================
echo.

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

echo Changing to application directory...
echo Current batch file location: %~dp0
cd /d "%~dp0"
echo Now in: %cd%
echo.

echo Running database migrations...
echo Please wait, this may take a while depending on your system...
cmd /c "php artisan migrate --force --step"
echo.

@REM echo.
@REM echo Launching application...
@REM start "" msedge.exe --app=http://class-record-client.test

echo ========================================
echo Setup Complete!
echo ========================================
echo Reached the end! Closing in 5 seconds...
echo.
echo If the window doesn't close automatically, you can close it manually.
timeout /t 5 /nobreak > nul
exit /b 0