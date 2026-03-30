@echo off
echo ========================================
echo  Testing Windows Security Exclusion
echo ========================================
echo.

echo Adding Windows Security exclusion for this folder...
echo A UAC prompt will appear - please click Yes to allow...
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"Add-MpPreference -ExclusionPath ''%~dp0''\"' -Verb RunAs -Wait"
echo.
echo Exclusion added for: %~dp0
echo.

echo Verifying exclusion was added...
powershell -Command "Get-MpPreference | Select-Object -ExpandProperty ExclusionPath"
echo.

echo ========================================
echo Done! Check above if your folder path
echo appears in the exclusion list.
echo ========================================
echo.
pause
