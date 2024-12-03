@echo off
setlocal enabledelayedexpansion

:menu
cls
echo.
echo Windows System Cleanup Utility
echo ============================
echo.
echo 1. Quick Clean (Logs + Temp)
echo 2. Compress C-Drive
echo 3. Empty Recycle Bin
echo 4. Windows Cache Cleanup
echo 5. Browser Cache Cleanup
echo 6. Windows Update Cleanup
echo 7. Network Reset
echo 8. Exit
echo.

choice /C 12345678 /N /M "Choose an option: "

if errorlevel 8 goto exit
if errorlevel 7 goto NetworkReset
if errorlevel 6 goto WindowsUpdate
if errorlevel 5 goto BrowserClean
if errorlevel 4 goto WinCache
if errorlevel 3 goto Trash
if errorlevel 2 goto Compress
if errorlevel 1 goto Clean

:GetSpace
for /f "tokens=*" %%a in ('powershell -command "[math]::Round((Get-PSDrive C).Free/1KB, 2)"') do set space=%%a
exit /b

:ShowSpace
set /a "savedMB=saved/1024"
set /a "savedGB=savedMB/1024"
set /a "savedMB_remainder=savedMB %% 1024"
set /a "savedKB=saved %% 1024"

echo.
if !savedGB! gtr 0 (
    echo Space saved: !savedGB! GB, !savedMB_remainder! MB, !savedKB! KB
) else if !savedMB! gtr 0 (
    echo Space saved: !savedMB! MB, !savedKB! KB
) else (
    echo Space saved: !savedKB! KB
)
exit /b

:Clean
cls
echo Running Quick Clean...
call :GetSpace
set initial=!space!

echo Cleaning Event Logs...
FOR /F "tokens=*" %%F in ('wevtutil.exe el') DO wevtutil.exe cl "%%F" 2>nul

echo Cleaning Temporary Files...
del /s /f /q "%TEMP%\*.*" 2>nul
del /s /f /q "%SystemRoot%\Temp\*.*" 2>nul
del /s /f /q "%SystemRoot%\Prefetch\*.*" 2>nul
del /s /q /f *.log *.dmp *.bak *.tmp *.old 2>nul

call :GetSpace
set final=!space!
set /a saved=final-initial
call :ShowSpace
pause
goto menu

:Compress
cls
echo Running Drive Compression...
call :GetSpace
set initial=!space!

compact /C /S /A /I /F /EXE:LZX *.exe
compact /CompactOs:always

call :GetSpace
set final=!space!
set /a saved=final-initial
call :ShowSpace
pause
goto menu

:Trash
cls
echo Emptying Recycle Bin...
call :GetSpace
set initial=!space!

rd /s /q %SystemDrive%\$Recycle.Bin 2>nul
PowerShell.exe -NoProfile -Command Clear-RecycleBin -Force -ErrorAction SilentlyContinue

call :GetSpace
set final=!space!
set /a saved=final-initial
call :ShowSpace
pause
goto menu

:WinCache
cls
echo Cleaning Windows Cache...
call :GetSpace
set initial=!space!

echo Cleaning DNS Cache...
ipconfig /flushdns

echo Cleaning Store Cache...
start /wait wsreset

echo Cleaning Thumbnail Cache...
del /f /s /q /a "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\iconcache_*.db" 2>nul

call :GetSpace
set final=!space!
set /a saved=final-initial
call :ShowSpace
pause
goto menu

:BrowserClean
cls
echo Cleaning Browser Caches...
call :GetSpace
set initial=!space!

echo Cleaning Chrome Cache...
del /q /s /f "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*" 2>nul
del /q /s /f "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache\*" 2>nul

echo Cleaning Firefox Cache...
del /q /s /f "%LocalAppData%\Mozilla\Firefox\Profiles\*.default\cache2\entries\*" 2>nul

echo Cleaning Edge Cache...
del /q /s /f "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*" 2>nul
del /q /s /f "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache\*" 2>nul

call :GetSpace
set final=!space!
set /a saved=final-initial
call :ShowSpace
pause
goto menu

:WindowsUpdate
cls
echo Cleaning Windows Update Cache...
call :GetSpace
set initial=!space!

echo Stopping Windows Update services...
net stop wuauserv
net stop bits

echo Removing update cache...
rd /s /q C:\Windows\SoftwareDistribution 2>nul

echo Restarting Windows Update services...
net start wuauserv
net start bits

call :GetSpace
set final=!space!
set /a saved=final-initial
call :ShowSpace
pause
goto menu

:NetworkReset
cls
echo Resetting Network Settings...
echo.
echo Resetting IP configuration...
ipconfig /release
ipconfig /flushdns
ipconfig /renew

echo Resetting Winsock and TCP/IP...
netsh winsock reset
netsh int ip reset

echo.
echo Network settings have been reset.
echo A system restart is recommended.
pause
goto menu

:exit
cls
echo Thank you for using Windows System Cleanup Utility
echo.
timeout /t 3 > nul
exit