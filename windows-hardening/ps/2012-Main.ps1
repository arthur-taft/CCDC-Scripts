param($ROOT = "C:\Users\$Env:UserName\Desktop")

$LOGS = "$ROOT\PS-LOGS"
$FREQ = 15

echo "`nCreating log file..."
New-Item -Path $LOGS\PS-MAINS-OUT.txt -Force -ItemType "file"
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
    echo "`n******************** CONFIGURING USERS ********************`n"

    echo "`nChanging current user's password..."
    $Password = Read-Host "Enter the new password for $env:username" -AsSecureString
    net user $env:username ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))

    echo "`nCreating new local user 'Printer'..."
    $Password = Read-Host "Enter the new password for Printer" -AsSecureString
    net user /add Printer ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))

    echo "`nDisabling all users except current and Printer...`n"
    Get-WmiObject -Class Win32_UserAccount | ForEach-Object {
        if ($_.Name -ne 'Administrator' -and $_.Name -ne 'Printer') {
            echo "Disabling $($_.Name)..."
            net user $_.Name /active:no
            }
        }

    echo "`nTo re-enable all users use this command:"
    echo "Get-WmiObject -Class Win32_UserAccount | ForEach-Object { if (`$_.Name -ne `"Guest`") { echo `"Enabling `$(`$_.Name)...`"; net user `$_.Name /active:yes } }"

    echo "`nGetting all local users..."
    Get-WmiObject -Class Win32_UserAccount | Select-Object *

    echo "`n******************** DISABLING ROLES AND FEATURES ********************`n"

    echo "`nDisabling SMB1..."
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

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

    #echo "`n******************** DEFENDER AND ANTIVIRUS ********************`n"

    #echo "`nUpdating signatures in new window..."
    #Start-Process powershell "echo 'Updating AV signatures...'; Update-MpSignature; pause"

    #echo "`nSetting protections on..."
    #Set-MpPreference -MAPSReporting Advanced
    #Set-MpPreference -SubmitSamplesConsent Always
    #Set-MpPreference -DisableBlockAtFirstSeen 0
    #Set-MpPreference -DisableIOAVProtection 0
    #Set-MpPreference -DisableRealtimeMonitoring 0
    #Set-MpPreference -DisableBehaviorMonitoring 0
    #Set-MpPreference -DisableScriptScanning 0
    #Set-MpPreference -DisableRemovableDriveScanning 0
    #Set-MpPreference -PUAProtection Enabled
    #Set-MpPreference -DisableArchiveScanning 0
    #Set-MpPreference -DisableEmailScanning 0
    #Set-MpPreference -CheckForSignaturesBeforeRunningScan 1

    #echo "`nGetting Defender and AV status"
    #Get-MpComputerStatus

    echo "`n******************** FIREWALL ********************`n"

    echo "`nEnabling Firewall...`n"
    Set-NetFirewallProfile Domain,Public,Private -Enabled True

    echo "`n******************** OPEN UPDATES ********************`n"

    control update
	
    echo "`n******************** SCHEDULE CHECKS TO RUN EVERY 15 MIN ********************`n"

    Copy-Item -Path $PSScriptRoot\2012-Checks.ps1 -Destination C:\
    $taskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $FREQ) -RepetitionDuration (New-TimeSpan -Days (365 * $FREQ))
    $taskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle hidden -F C:\2012-Checks.ps1"

    Register-ScheduledTask 'Run-Checks' -Action $taskAction -Trigger $taskTrigger
    Start-ScheduledTask 'Run-Checks'

} | Tee-Object $LOGS\PS-MAINS-OUT.txt