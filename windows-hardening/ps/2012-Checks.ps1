param($ROOT = "C:\Users\$Env:UserName\Desktop\PS-LOGS")

$TIME = Get-Date -Format "HH-mm"

echo "`nCreating log file..."
New-Item -Path $ROOT\SMB-SHARES-$TIME.txt -Force -ItemType "file"

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
    echo "`n******************** GETTING SMB SHARES ********************`n"

    Get-SMBShare
    Get-SmbShare | Get-SmbShareAccess

} | Tee-Object $ROOT\SMB-SHARES-$TIME.txt