param($ROOT = "C:\Users\$Env:UserName\Desktop")

$ProgressPreference = 'SilentlyContinue'
$DOCS = "C:\Users\$Env:UserName\Documents"
$LOGS = "$ROOT\PS-LOGS"

Start-Transcript -Path "$LOGS\PS-PACKAGE-MAN-OUT.txt"

. {
    $CHOCO_URL = "https://community.chocolatey.org/install.ps1"

    echo "`n******************** DOWNLOADING AND INSTALLING WINGET ********************`n"

    Install-Script -Name winget-install

    echo "`n******************** DOWNLOADING AND INSTALLING CHOCO ********************`n"

    wget $CHOCO_URL -OutFile "$ROOT\choco-install.ps1"

    Invoke-Expression -Command "$ROOT\choco-install.ps1"

} | Out-Default

Stop-Transcript
