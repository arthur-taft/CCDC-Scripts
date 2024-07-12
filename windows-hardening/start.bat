powershell ps\2016-Prelims.ps1
powershell ps\2016-Main.ps1
powershell ps\2016-Checks.ps1

ping 8.8.8.8
ping google.com
echo Download software?

SET install= N
SET /p install= Yes[Y] No[N] (default is No) 

IF %install%==Y (
	powershell ps\2016-Software.ps1
)

IF %install%==Yes (
	powershell ps\2016-Software.ps1
)

SET install= N

echo Rebooting is required for changes to happen. Restart Now?
SET restart= N
SET /p restart= Yes[Y] No[N] (default is No) 

IF %restart%==Y (
	shutdown -r -t 0
)

IF %restart%==Yes (
	shutdown -r -t 0
)

pause