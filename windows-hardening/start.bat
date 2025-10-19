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
echo ******************** PINGING 8.8.8.8 ********************
echo.
ping 8.8.8.8

echo.
echo ******************** PINGING amazon.com ********************
echo.
ping amazon.com

echo.
echo ******************** PROMPT FOR SOFTWARE INSTALL ********************
echo.
echo Install Software?
SET install=n
SET /p install="Yes[Y] No[N] (default is No): "

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

echo.
echo ******************** UPDATE EXECUTION POLICY ********************
echo.
echo Setting execution policy to Restricted...
powershell Set-ExecutionPolicy -ExecutionPolicy Restricted

echo.
echo ******************** PROMPT FOR REBOOT ********************
echo.
echo Rebooting is required for changes to happen. Restart Now?
SET restart=n
SET /p restart="Yes[Y] No[N] (default is No): "

IF %restart%==y (
	shutdown -r -t 0
)

IF %restart%==yes (
	shutdown -r -t 0
)

pause
