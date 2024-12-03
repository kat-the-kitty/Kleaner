@echo off
setlocal enabledelayedexpansion
cd C:\

:menu
cls
echo.
echo Windows System Cleanup Utility
echo ============================
echo.
echo 1. Quick Clean (Logs + Temp)
echo 2. Compress C-Drive
echo 3. Empty Recycle Bin
echo 4. Bloatware Remover
echo 5. Disk Analysis
echo 6. Windows Cache Cleanup
echo 7. Browser Cache Cleanup
echo 8. System File Check
echo 9. Disk Defragmentation
echo 10. Windows Update Cleanup
echo 11. Network Reset
echo 12. Exit
echo.

choice /C 123456789ABC /N /M "Choose an option: "

if errorlevel 12 goto exit
if errorlevel 11 goto NetworkReset
if errorlevel 10 goto WindowsUpdate
if errorlevel 9 goto Defrag
if errorlevel 8 goto SFC
if errorlevel 7 goto BrowserClean
if errorlevel 6 goto WinCache
if errorlevel 5 goto DiskAnalysis
if errorlevel 4 goto Debloat
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
del /s /f /q "*\Temp\*" 2>nul
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

:Debloat
cls
echo Running Bloatware Remover...
if exist "C:\Kayden\Kleaner\Main\10AppsManager.exe" (
    start "" "C:\Kayden\Kleaner\Main\10AppsManager.exe"
    echo Started Bloatware Removal Tool
) else (
    echo Bloatware removal tool not found.
)
pause
goto menu

:DiskAnalysis
cls
echo Current Disk Space:
echo.
powershell -Command "$disk = Get-WmiObject Win32_LogicalDisk -Filter 'DeviceID=''C:'''; [PSCustomObject]@{Drive='C:'; 'Size(GB)'=[math]::Round($disk.Size/1GB,2); 'Free(GB)'=[math]::Round($disk.FreeSpace/1GB,2); 'Free(MB)'=[math]::Round($disk.FreeSpace/1MB,2); 'Free(KB)'=[math]::Round($disk.FreeSpace/1KB,2)} | Format-List"
echo.
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

:SFC
cls
echo Running System File Check...
echo This may take several minutes...
echo.
sfc /scannow
echo.
pause
goto menu

:Defrag
cls
echo Running Disk Defragmentation...
echo.
defrag C: /A /V
echo.
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