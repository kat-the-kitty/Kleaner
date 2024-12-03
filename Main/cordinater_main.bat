@echo off
setlocal enabledelayedexpansion
cd C:\

:menu
cls
echo.
echo Windows System Cleanup Utility
echo ============================
echo.
echo 1. Quick Clean (All Caches + Logs)
echo 2. Compress C-Drive
echo 3. Empty Recycle Bin
echo 4. Exit
echo.

choice /C 1234 /N /M "Choose an option: "

if errorlevel 4 goto exit
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
echo Running Enhanced Quick Clean...
call :GetSpace
set initial=!space!

echo Searching and Cleaning All Temp Directories...
for /f "delims=" %%D in ('dir /s /b /ad "*Temp"') do (
    echo Cleaning: %%D
    rd /s /q "%%D" 2>nul
    md "%%D" 2>nul
)

echo Cleaning System Files and Logs...
FOR /F "tokens=*" %%F in ('wevtutil.exe el') DO wevtutil.exe cl "%%F" 2>nul

echo Cleaning Standard Temp Locations...
del /s /f /q "%TEMP%\*.*" 2>nul
del /s /f /q "%SystemRoot%\Temp\*.*" 2>nul
del /s /f /q "%SystemRoot%\Prefetch\*.*" 2>nul
del /s /f /q "%USERPROFILE%\AppData\Local\Temp\*.*" 2>nul
del /s /f /q "%ALLUSERSPROFILE%\Temp\*.*" 2>nul

echo Cleaning Additional Temp Files...
del /s /q /f *.log *.dmp *.bak *.tmp *.old *.err *.crash *.stackdump *.swd *.swp *.thumbs.db 2>nul

echo Cleaning Font Cache...
net stop FontCache
del /f /s /q "%systemroot%\System32\FNTCACHE.DAT" 2>nul
net start FontCache

echo Cleaning Thumbnail Cache...
del /f /s /q /a "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\iconcache_*.db" 2>nul

echo Cleaning Windows Store Cache...
del /f /s /q "%LocalAppData%\Packages\*\AC\INetCache\*" 2>nul
del /f /s /q "%LocalAppData%\Packages\*\AC\INetHistory\*" 2>nul
del /f /s /q "%LocalAppData%\Packages\*\AC\Temp\*" 2>nul
del /f /s /q "%LocalAppData%\Packages\*\AC\TokenBroker\Cache\*" 2>nul

echo Cleaning System Caches...
ipconfig /flushdns
start /wait wsreset
del /f /s /q "%SystemRoot%\System32\drivers\etc\hosts.ics" 2>nul
del /f /s /q "%ProgramData%\Microsoft\Search\Data\Applications\Windows\Windows.edb" 2>nul
del /f /s /q "%SystemRoot%\System32\LogFiles\*.*" 2>nul
del /f /s /q "%ProgramData%\Microsoft\Windows\WER\*.*" 2>nul
del /f /s /q "%SystemRoot%\Logs\*.*" 2>nul
del /f /s /q "%LocalAppData%\Microsoft\Windows\WebCache\*.*" 2>nul

echo Cleaning DirectX Shader Cache...
del /s /f /q "%LocalAppData%\D3DSCache\*.*" 2>nul
del /s /f /q "%LocalAppData%\NVIDIA\DXCache\*.*" 2>nul
del /s /f /q "%LocalAppData%\AMD\DXCache\*.*" 2>nul

echo Cleaning Delivery Optimization Files...
del /s /f /q "%SystemRoot%\SoftwareDistribution\Download\*.*" 2>nul
net stop DoSvc 2>nul
del /s /f /q "%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*.*" 2>nul
net start DoSvc 2>nul

echo Cleaning Browser Caches...
rem Chrome (all profiles)
for /d %%x in ("%LocalAppData%\Google\Chrome\User Data\*") do (
    del /s /f /q "%%x\Cache\*" 2>nul
    del /s /f /q "%%x\Code Cache\*" 2>nul
    del /s /f /q "%%x\Media Cache\*" 2>nul
)

rem Firefox (all profiles)
for /d %%x in ("%LocalAppData%\Mozilla\Firefox\Profiles\*") do (
    del /s /f /q "%%x\cache2\entries\*" 2>nul
    del /s /f /q "%%x\startupCache\*" 2>nul
)

rem Edge (all profiles)
for /d %%x in ("%LocalAppData%\Microsoft\Edge\User Data\*") do (
    del /s /f /q "%%x\Cache\*" 2>nul
    del /s /f /q "%%x\Code Cache\*" 2>nul
    del /s /f /q "%%x\Media Cache\*" 2>nul
)

rem Opera
del /s /f /q "%LocalAppData%\Opera Software\Opera Stable\Cache\*" 2>nul

rem Brave
del /s /f /q "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache\*" 2>nul

echo Cleaning Windows Update Cache...
net stop wuauserv
net stop bits
rd /s /q C:\Windows\SoftwareDistribution 2>nul
net start wuauserv
net start bits

echo Resetting Network...
ipconfig /release
ipconfig /flushdns
ipconfig /renew
netsh winsock reset
netsh int ip reset

echo Cleaning Recent Items...
del /f /s /q "%APPDATA%\Microsoft\Windows\Recent\*.*" 2>nul
del /f /s /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*.*" 2>nul
del /f /s /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*.*" 2>nul

echo Cleaning Other Common Temp Locations...
del /s /f /q "%LocalAppData%\CrashDumps\*.*" 2>nul
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*.*" 2>nul
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCookies\*.*" 2>nul
del /s /f /q "%USERPROFILE%\Downloads\Temp\*.*" 2>nul

call :GetSpace
set final=!space!
set /a saved=final-initial
echo.
echo Enhanced Quick Clean Complete!
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

:exit
cls
echo Thank you for using Windows System Cleanup Utility
echo.
timeout /t 3 > nul
exit