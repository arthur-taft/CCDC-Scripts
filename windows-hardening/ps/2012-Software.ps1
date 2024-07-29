param($ROOT = "C:\Users\$Env:UserName\Desktop")

$LOGS = "$ROOT\PS-LOGS"

$WAZUH_URL = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.8.0-1.msi"
$KF_URL = "https://www.kfsensor.net/kfsensor/download/kfsens40.msi"
$REG_URL = "https://github.com/Seabreg/Regshot/raw/468afc89c23a539c8c555900cad1b4f1eb58e51f/Regshot-x64-ANSI.exe"
$AUTORUNS_URL = "https://download.sysinternals.com/files/Autoruns.zip"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

echo "`nCreating log file..."
New-Item -Path $LOGS\PS-SOFTWARE-OUT.txt -Force -ItemType "file"
Set-Alias -Name wget -Value Invoke-WebRequest

. {
    echo `n"
**************************************
Start Time: $(get-date)
UserName: $env:username
UserDomain: $env:USERDNSDOMAIN
ComputerName: $env:COMPUTERNAME
Windows version: $((Get-WmiObject win32_operatingsystem).version)
**************************************
"

    echo "`n******************** DOWNLOADING AND INSTALLING WAZUH AGENT ********************`n"

    wget $WAZUH_URL -OutFile "$ROOT\wazuh-agent.msi"
    $IP = Read-Host "Enter the wazuh manager IP"
    & $ROOT\wazuh-agent.msi /q WAZUH_MANAGER=$IP
    Start-Sleep -Seconds 4
    NET START Wazuh

    echo "`n******************** DOWNLOADING AUTORUNS ********************`n"

    wget $AUTORUNS_URL -OutFile $ROOT\autoruns.zip
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$ROOT\autoruns.zip", "$ROOT\autoruns")

    echo "`n******************** DOWNLOADING REGSHOT ********************`n"

    wget $REG_URL -OutFile "$ROOT\regshot.exe"

} | Tee-Object $LOGS\PS-SOFTWARE-OUT.txt