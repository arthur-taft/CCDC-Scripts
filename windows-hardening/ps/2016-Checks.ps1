param($ROOT = "C:\Users\$Env:UserName\Desktop\PS-LOGS")

$TIME = Get-Date -Format "HH-mm"

Start-Transcript -Path "$ROOT\SMB-SHARES-$TIME.txt"

. {
    echo "`n******************** GETTING SMB SHARES ********************`n"

    Get-SMBShare
    Get-SmbShare | Get-SmbShareAccess

} | Out-Default

Stop-Transcript