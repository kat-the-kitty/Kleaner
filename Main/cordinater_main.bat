@echo off
setlocal enabledelayedexpansion
cd C:\

:menu
cls
echo =====================================
echo Windows System Cleanup Utility
echo =====================================
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
timeout /t 1 /nobreak >nul
for /f "tokens=*" %%a in ('powershell -command "$([math]::Round((Get-PSDrive C).Free))"') do set space=%%a
exit /b

:ShowSpace
if %final% LSS %initial% (
    echo No measurable space was saved
    pause
    goto menu
)

set /a saved=%final%-%initial%
set /a savedGB=%saved%/1073741824
set /a savedMB=(%saved%/1048576) %% 1024
set /a savedKB=(%saved%/1024) %% 1024
set /a savedB=%saved% %% 1024

echo.
if !savedGB! gtr 0 (
    echo Space saved: !savedGB! GB, !savedMB! MB
) else if !savedMB! gtr 0 (
    echo Space saved: !savedMB! MB, !savedKB! KB
) else if !savedKB! gtr 0 (
    echo Space saved: !savedKB! KB
) else (
    echo Space saved: !savedB! bytes
)
exit /b

:Clean
cls
echo =====================================
echo Starting Enhanced Quick Clean...
echo =====================================
call :GetSpace
set initial=!space!

echo [%time%] Finding and Processing Temp Directories...
echo ----------------------------------------
echo.
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\" (
        pushd "%%d:\" && (
            echo Searching drive %%d:
            dir /s /b /ad "*temp" | (
                for /f "delims=" %%D in ('more') do (
                    echo Found: %%~fD
                    dir "%%~fD"
                    echo Cleaning...
                    rd /s /q "%%~fD"
                    md "%%~fD"
                    echo Cleaned: %%~fD
                    echo ----------------------------------------
                )
            )
            popd
        )
    )
)

echo.
echo [%time%] Starting Windows Temp Cleanup...
echo ----------------------------------------
for %%D in (
    "%SystemRoot%\Temp"
    "%TEMP%"
    "%SystemRoot%\Prefetch"
    "%USERPROFILE%\AppData\Local\Temp"
    "%ALLUSERSPROFILE%\Temp"
) do (
    echo.
    echo Cleaning: %%~D
    for /f "delims=" %%F in ('dir /s /b "%%~D\*" 2^>nul') do (
        echo   Removing: %%F
        del /f /q "%%F" 2>nul
    )
)

echo.
echo [%time%] Clearing Event Logs...
echo ----------------------------------------
for /F "tokens=*" %%F in ('wevtutil.exe el') do (
    echo Clearing log: %%F
    wevtutil.exe cl "%%F" 2>nul
)

echo.
echo [%time%] Cleaning Temporary Files System-Wide...
echo ----------------------------------------
for %%x in (log dmp bak tmp old err crash stackdump swd swp thumbs.db) do (
    echo.
    echo Scanning for *.%%x files...
    for /f "delims=" %%F in ('dir /s /b "C:\*.%%x" 2^>nul') do (
        echo   Removing: %%F
        del /f /q "%%F" 2>nul
    )
)

echo.
echo [%time%] Managing Font Cache...
echo ----------------------------------------
echo Stopping FontCache service...
net stop FontCache
echo Removing FNTCACHE.DAT...
del /f /s /q "%systemroot%\System32\FNTCACHE.DAT" 2>nul
echo Starting FontCache service...
net start FontCache

echo.
echo [%time%] Cleaning System Caches...
echo ----------------------------------------
echo Cleaning thumbnail cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Microsoft\Windows\Explorer\iconcache_*.db" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo Cleaning Windows Store cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Packages\*\AC\INetCache\*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Packages\*\AC\INetHistory\*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Packages\*\AC\Temp\*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Packages\*\AC\TokenBroker\Cache\*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo Running DNS flush...
ipconfig /flushdns

echo Running Windows Store reset...
start /wait wsreset

echo Cleaning system caches...
for /f "delims=" %%F in ('dir /s /b "%SystemRoot%\System32\LogFiles\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%ProgramData%\Microsoft\Windows\WER\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%SystemRoot%\Logs\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Microsoft\Windows\WebCache\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo.
echo [%time%] Cleaning Graphics Caches...
echo ----------------------------------------
echo Cleaning DirectX Shader Cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\D3DSCache\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
echo Cleaning NVIDIA Cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\NVIDIA\DXCache\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
echo Cleaning AMD Cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\AMD\DXCache\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo.
echo [%time%] Cleaning Browser Caches...
echo ----------------------------------------
echo Cleaning Chrome profiles...
for /d %%x in ("%LocalAppData%\Google\Chrome\User Data\*") do (
    echo Processing Chrome profile: %%x
    for /f "delims=" %%F in ('dir /s /b "%%x\Cache\*" "%%x\Code Cache\*" "%%x\Media Cache\*" 2^>nul') do (
        echo   Removing: %%F
        del /f /q "%%F" 2>nul
    )
)

echo Cleaning Firefox profiles...
for /d %%x in ("%LocalAppData%\Mozilla\Firefox\Profiles\*") do (
    echo Processing Firefox profile: %%x
    for /f "delims=" %%F in ('dir /s /b "%%x\cache2\entries\*" "%%x\startupCache\*" 2^>nul') do (
        echo   Removing: %%F
        del /f /q "%%F" 2>nul
    )
)

echo Cleaning Edge profiles...
for /d %%x in ("%LocalAppData%\Microsoft\Edge\User Data\*") do (
    echo Processing Edge profile: %%x
    for /f "delims=" %%F in ('dir /s /b "%%x\Cache\*" "%%x\Code Cache\*" "%%x\Media Cache\*" 2^>nul') do (
        echo   Removing: %%F
        del /f /q "%%F" 2>nul
    )
)

echo Cleaning Opera cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Opera Software\Opera Stable\Cache\*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo Cleaning Brave cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache\*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo.
echo [%time%] Managing Windows Update Cache...
echo ----------------------------------------
echo Stopping Windows Update services...
net stop wuauserv
net stop bits
echo Removing SoftwareDistribution folder...
rd /s /q C:\Windows\SoftwareDistribution 2>nul
echo Restarting Windows Update services...
net start wuauserv
net start bits

echo.
echo [%time%] Performing Network Reset...
echo ----------------------------------------
echo Running ipconfig release...
ipconfig /release
echo Flushing DNS...
ipconfig /flushdns
echo Running ipconfig renew...
ipconfig /renew
echo Resetting Winsock...
netsh winsock reset
echo Resetting IP stack...
netsh int ip reset

echo.
echo [%time%] Cleaning User Data...
echo ----------------------------------------
echo Cleaning Recent Items...
for /f "delims=" %%F in ('dir /s /b "%APPDATA%\Microsoft\Windows\Recent\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)
for /f "delims=" %%F in ('dir /s /b "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo Cleaning crash dumps...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\CrashDumps\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo Cleaning Internet cache...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Microsoft\Windows\INetCache\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo Cleaning cookies...
for /f "delims=" %%F in ('dir /s /b "%LocalAppData%\Microsoft\Windows\INetCookies\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

echo Cleaning downloads temp...
for /f "delims=" %%F in ('dir /s /b "%USERPROFILE%\Downloads\Temp\*.*" 2^>nul') do (
    echo   Removing: %%F
    del /f /q "%%F" 2>nul
)

call :GetSpace
set final=!space!

echo.
echo =====================================
echo Enhanced Quick Clean Complete!
echo =====================================
call :ShowSpace
pause
goto menu

:Compress
cls
echo =====================================
echo Starting Drive Compression...
echo =====================================
call :GetSpace
set initial=!space!

echo.
echo [%time%] Compressing System Files...
echo ----------------------------------------
echo Compressing EXE files across drive...
compact /C /S /A /I /F /EXE:LZX *.exe
echo.
echo [%time%] Compressing Operating System...
echo ----------------------------------------
echo Enabling OS compression...
compact /CompactOs:always

call :GetSpace
set final=!space!
echo.
echo =====================================
echo Drive Compression Complete!
echo =====================================
call :ShowSpace
pause
goto menu

:Trash
cls
echo =====================================
echo Starting Recycle Bin Cleanup...
echo =====================================
call :GetSpace
set initial=!space!

echo.
echo [%time%] Clearing Recycle Bin Contents...
echo ----------------------------------------
echo Removing Recycle Bin directory...
rd /s /q %SystemDrive%\$Recycle.Bin 2>nul
echo Using PowerShell for thorough cleanup...
PowerShell.exe -NoProfile -Command Clear-RecycleBin -Force -ErrorAction SilentlyContinue

call :GetSpace
set final=!space!
echo.
echo =====================================
echo Recycle Bin Cleanup Complete!
echo =====================================
call :ShowSpace
pause
goto menu

:exit
exit