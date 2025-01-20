param($ROOT = "C:\Users\$Env:UserName\Desktop")

$DOCS = "C:\Users\$Env:UserName\Documents"
$LOGS = "$ROOT\PS-LOGS"

Start-Transcript -Path "$LOGS\PS-SOFTWARE-OUT.txt"

. {
    $WAZUH_URL = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.8.0-1.msi"
    $KF_URL = "https://www.kfsensor.net/kfsensor/download/kfsens40.msi"
    $REG_MAN_URL = "https://www.resplendence.com/download/RegistrarHomeV9.exe"
    $SYSINTERNALS_URL = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    $2016_BASELINE_URL = "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%2010%20Version%201607%20and%20Windows%20Server%202016%20Security%20Baseline.zip"
    $LGPO_URL = "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip"
    $POLICYANALYZER_URL = "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/PolicyAnalyzer.zip"
	Function InstallHardeningKitty() {
    	$Version = (((Invoke-WebRequest "https://api.github.com/repos/0x6d69636b/windows_hardening/releases/latest" -UseBasicParsing) | ConvertFrom-Json).Name).SubString(2)
    	$HardeningKittyLatestVersionDownloadLink = ((Invoke-WebRequest "https://api.github.com/repos/0x6d69636b/windows_hardening/releases/latest" -UseBasicParsing) | ConvertFrom-Json).zipball_url
    	$ProgressPreference = 'SilentlyContinue'
    	Invoke-WebRequest $HardeningKittyLatestVersionDownloadLink -Out HardeningKitty$Version.zip
    	Expand-Archive -Path ".\HardeningKitty$Version.zip" -Destination ".\HardeningKitty$Version" -Force
    	$Folder = Get-ChildItem .\HardeningKitty$Version | Select-Object Name -ExpandProperty Name
    	Move-Item ".\HardeningKitty$Version\$Folder\*" ".\HardeningKitty$Version\"
    	Remove-Item ".\HardeningKitty$Version\$Folder\"
    	New-Item -Path $Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version -ItemType Directory
    	Set-Location .\HardeningKitty$Version
    	Copy-Item -Path .\HardeningKitty.psd1,.\HardeningKitty.psm1,.\lists\ -Destination $Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version\ -Recurse
    	Import-Module "$Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version\HardeningKitty.psm1"
	}

    echo "`n******************** DOWNLOADING AND INSTALLING WAZUH AGENT ********************`n"

    wget $WAZUH_URL -OutFile "$ROOT\wazuh-agent.msi"
    $IP = Read-Host "Enter the wazuh manager IP"
    & $ROOT\wazuh-agent.msi /q WAZUH_MANAGER=$IP
    Start-Sleep -Seconds 4
    NET START Wazuh

    echo "`n******************** DOWNLOADING KF SENSOR HONEYPOT INSTALLER ********************`n"

    wget $KF_URL -OutFile "$ROOT\kfsense-installer.msi"

    echo "`n******************** DOWNLOADING SYSINTERNALS ********************`n"

    wget $SYSINTERNALS_URL -OutFile $DOCS\sysinternals.zip
    Expand-Archive -Path $DOCS\sysinternals.zip -DestinationPath $ROOT\sysinternals

    echo "`n******************** DOWNLOADING REGISTRY MANAGER INSTALLER ********************`n"

    wget $REG_MAN_URL -OutFile "$ROOT\regman-installer.exe"

	echo "`n******************** DOWNLOADING AND INSTALLING HARDENINGKITTY********************`n"

	InstallHardeningKitty
	Invoke-HardeningKitty -Mode Config -Backup

} | Out-Default

Stop-Transcript
