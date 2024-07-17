param($ROOT = "C:\Users\$Env:UserName\Desktop")

$LOGS = "$ROOT\PS-LOGS"
$FREQ = 15

Start-Transcript -Path $LOGS\PS-MAINS-OUT.txt
. {
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
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

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

    echo "`nUpdating signatures in new window..."
    Start-Process powershell "echo 'Updating AV signatures...'; Update-MpSignature"

    echo "`nSetting protections on..."
    Set-MpPreference -MAPSReporting Advanced
    Set-MpPreference -SubmitSamplesConsent Always
    Set-MpPreference -DisableBlockAtFirstSeen 0
    Set-MpPreference -DisableIOAVProtection 0
    Set-MpPreference -DisableRealtimeMonitoring 0
    Set-MpPreference -DisableBehaviorMonitoring 0
    Set-MpPreference -DisableScriptScanning 0
    Set-MpPreference -DisableRemovableDriveScanning 0
    Set-MpPreference -PUAProtection Enabled
    Set-MpPreference -DisableArchiveScanning 0
    Set-MpPreference -DisableEmailScanning 0
    Set-MpPreference -CheckForSignaturesBeforeRunningScan 1

    echo "`nGetting Defender and AV status"
    Get-MpComputerStatus

    echo "`n******************** FIREWALL ********************`n"

    echo "`nEnabling Firewall...`n"
    Set-NetFirewallProfile Domain,Public,Private -Enabled True

	echo "`n******************** OPEN UPDATES ********************`n"

	start ms-settings:windowsupdate
	
    echo "`n******************** SCHEDULE CHECKS TO RUN EVERY 15 MIN ********************`n"

    Copy-Item -Path $PSScriptRoot\2016-Checks.ps1 -Destination C:\
    $taskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $FREQ) -RepetitionDuration (New-TimeSpan -Days (365 * $FREQ))
    $taskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle hidden -F C:\2016-Checks.ps1"

    Register-ScheduledTask 'Run-Checks' -Action $taskAction -Trigger $taskTrigger
    Start-ScheduledTask 'Run-Checks'

} | Out-Default

Stop-Transcript