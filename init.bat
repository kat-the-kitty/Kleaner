@echo off
cd /d "%~dp0"
NSudoLC.exe -U:T -P:E -M:S -Priority:RealTime -ShowWindowMode:Show cmd /k "cd /d "%~dp0\Main" && cordinater_main.bat"