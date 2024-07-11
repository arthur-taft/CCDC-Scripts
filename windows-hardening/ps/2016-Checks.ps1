param($ROOT = "C:\Users\$Env:UserName\Desktop\PS-LOGS")

$TIME = Get-Date -Format "HH-mm"

Start-Transcript -Path "$ROOT\SMB-SHARES-$TIME.txt"

. {
    echo "`n******************** GETTING SMB SHARES ********************`n"

    Get-SMBShare
    Get-SmbShare | Get-SmbShareAccess

} | Out-Default

Stop-Transcript

Start-Transcript -Path "$ROOT\SERVICES-$TIME.txt"

. {
    echo "`n******************** GETTING SERVICES ********************`n"

} | Out-Default

Stop-Transcript

Start-Transcript -Path "$ROOT\PROCESSES-$TIME.txt"

. {
    echo "`n******************** GETTING PROCESSES ********************`n"

} | Out-Default

Stop-Transcript