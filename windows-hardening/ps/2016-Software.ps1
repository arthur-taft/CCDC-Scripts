param($ROOT = "C:\Users\$Env:UserName\Desktop")

$LOGS = "$ROOT\PS-LOGS"

Start-Transcript -Path "$LOGS\PS-SOFTWARE-OUT.txt"

. {
    $WAZUH_URL = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.8.0-1.msi"
    $KF_URL = "https://www.kfsensor.net/kfsensor/download/kfsens40.msi"
    $REG_URL = "https://github.com/Seabreg/Regshot/raw/468afc89c23a539c8c555900cad1b4f1eb58e51f/Regshot-x64-ANSI.exe"
    $AUTORUNS_URL = "https://download.sysinternals.com/files/Autoruns.zip"

    echo "`n******************** DOWNLOADING AND INSTALLING WAZUH AGENT ********************`n"

    wget $WAZUH_URL -OutFile "$ROOT\wazuh-agent.msi"
    $IP = Read-Host "Enter the wazuh manager IP"
    & $ROOT\wazuh-agent.msi /q WAZUH_MANAGER=$IP
    Start-Sleep -Seconds 4
    NET START Wazuh

    echo "`n******************** DOWNLOADING KF SENSOR HONEYPOT ********************`n"

    wget $KF_URL -OutFile "$ROOT\kfsense.msi"

    echo "`n******************** DOWNLOADING AUTORUNS ********************`n"

    wget $AUTORUNS_URL -OutFile $ROOT\autoruns.zip
    Expand-Archive -Path $ROOT\autoruns.zip -DestinationPath $ROOT\autoruns

    echo "`n******************** DOWNLOADING REGSHOT ********************`n"

    wget $REG_URL -OutFile "$ROOT\regshot.exe"
    & $ROOT\regshot.exe

} | Out-Default

Stop-Transcript