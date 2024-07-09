Start-Transcript -Path "C:\Users\$Env:UserName\Desktop\PS-OUT.txt"

echo "`n******************** CONFIGURING USERS ********************`n"

echo "`nChanging current user's password..."
$UserAccount = Get-LocalUser -Name $($Env:UserName)
$Password = Read-Host "Enter the new password for $UserAccount" -AsSecureString
$UserAccount | Set-LocalUser -Password $Password

echo "`nCreating new local user 'Printer'..."
$Password = Read-Host "Enter the new password for Printer" -AsSecureString
New-LocalUser -Name Printer -Password $Password

echo "`nDisabling all users except current and Printer..."
Get-LocalUser | Where-Object {$_.Name -ne $Env:UserName -and $_.Name -ne "Printer"} | Disable-LocalUser

echo "`nTo re-enable all users use this command:"
echo "Get-LocalUser | Where-Object {`$_.Name -ne `"Guest`" -and `$_.Name -ne `"DefaultAccount`"} | Enable-LocalUser"

echo "`nGetting all local users..."
Get-LocalUser

echo "`n******************** DISABLING ROLES AND FEATURES ********************`n"

echo "`nDisabling SMB1..."
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -Force

echo "`nDisabling RDP..."
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 1
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"

echo "`nDisabling Remote Management..."
Disable-PSRemoting -Force
Configure-SMremoting.exe -disable

echo "`n-Removing WinRM listeners..."
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse -Force

echo "`n-Disabling WinRM firewall rules..."
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system -Name LocalAccountTokenFilterPolicy -Value 0

echo "`n-Stopping and disabling WinRM service..."
Stop-Service WinRM
Set-Service WinRM -StartupType Disabled -PassThru

echo "`nStopping and disabling Printer Spooler service..."
Stop-Service Spooler
Set-Service Spooler -StartupType Disabled -PassThru

echo "`n******************** DEFENDER AND ANTIVIRUS ********************`n"

echo "`nUpdating signatures is disabled by default (it takes a while to download)..."
#Update-MpSignature

echo "`nGetting Defender and AV status"
Get-MpComputerStatus

echo "`n******************** FIREWALL ********************`n"

echo "`nEnabling Firewall...`n"
Set-NetFirewallProfile Domain,Public,Private -Enabled True

echo "`n******************** INSTALLING WAZUH AGENT ********************`n"

wget https://packages.wazuh.com/4.x/windows/wazuh-agent-4.8.0-1.msi -OutFile "wazuh-agent-4.8.0-1.msi"
$IP = Read-Host "Enter the wazuh manager IP"
.\wazuh-agent-4.8.0-1.msi /q WAZUH_MANAGER=$IP
Start-Sleep -Seconds 2
NET START Wazuh

Stop-Transcript