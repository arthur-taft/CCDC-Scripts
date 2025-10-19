@ECHO OFF 
echo.
echo Setting execution policy to RemoteSigned...
powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


::FOR /F "tokens=2" %%g IN ('powershell $PSVersionTable ^| findstr /C:"PSVersion"') do (SET version=%%g)
::
::IF %version% LEQ 5.1 (
::	powershell .\2012-update-fix.msu
::	powershell ps\2012-Prelims.ps1
::	powershell ps\2012-Main.ps1
::)

::IF NOT %version% LSS 5.1 (
	powershell ps\2016-Prelims.ps1
	powershell ps\2016-Main.ps1
::)

echo.
echo Pinging 8.8.8.8...
ping 8.8.8.8
echo.

echo Pinging amazon.com...
ping amazon.com

echo.
echo Download software?
SET install=n
echo.
SET /p install="Yes[Y] No[N] (default is No): "
echo.

IF %install%==y (
	powershell ps\2016-Software.ps1
)
::	IF %version% LEQ 5.1 (
::		powershell ps\2012-Software.ps1
::	)
::
::	IF NOT %version% LSS 5.1 (
::		powershell ps\2016-Software.ps1
::	)
::)

echo Setting execution policy to Restricted...
powershell Set-ExecutionPolicy -ExecutionPolicy Restricted

echo.
echo Rebooting is required for changes to happen. Restart Now?
SET restart=n
echo.
SET /p restart="Yes[Y] No[N] (default is No): "

IF %restart%==y (
	shutdown -r -t 0
)

IF %restart%==yes (
	shutdown -r -t 0
)

pause
