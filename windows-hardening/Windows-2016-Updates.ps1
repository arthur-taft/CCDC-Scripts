echo "`n******************** STARTING WINDOWS UPDATE ********************`n"

echo "`nInstalling PSWindowsUpdate module..."
powershell Install-Module PSWindowsUpdate -Force

echo "`nGetting updates..."
Get-WindowsUpdate

echo "`nInstalling updates..."
Install-WindowsUpdate

echo "`n***IF YOU RUN INTO ERRORS RUN THESE TWO COMMANDS AND RESTART THIS SCRIPT***"
echo "`nSet-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord"
echo "`nSet-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord"