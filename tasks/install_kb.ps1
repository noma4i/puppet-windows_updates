[CmdletBinding()]
Param(
  [Parameter(Mandatory = $True)] [String]  $kb,
  [Parameter(Mandatory = $True)] [Boolean] $restart
)

$ProgressPreference = 'SilentlyContinue'
$LibDir = "$env:ProgramData\PuppetLabs\puppet\cache\lib\windows_updates"
$LibDir += "\errorcodes.txt"
$all_error_codes = Get-Content -raw -Path $LibDir | ConvertFrom-StringData

[void](Install-WindowsUpdate -KBArticleID "$KB" -AcceptAll -IgnoreReboot)
Start-Sleep 5
$update = Get-WUHistory | ? KB -eq $KB | Sort-Object Date -Descending | Select-Object -First 1
switch -regex ($update.Result) {
    'Succeeded' {
        Set-Content "C:\ProgramData\InstalledUpdates\$KB.flg" "Installed"
        if ($restart) {
            Write-Output "Restart parameter enabled, restarting node in 30 seconds"
            & shutdown -r -t 30
        }
    }
    'SucceededWithErrors|InProgress' {
        $HResult = [Convert]::ToString($update.HResult, 16)
        $Message = $all_error_codes["0x$HResult"]
        Write-Output "Update $KB was installed but reported (likely reboot needed): $Message"
        Set-Content "C:\ProgramData\InstalledUpdates\$KB.flg" "Installed"
        if ($restart) {
            Write-Output "Restart parameter enabled, restarting node in 30 seconds"
            & shutdown -r -t 30
        }
    }
    'Failed' {
        $HResult = [Convert]::ToString($update.HResult, 16)
        $Message = $all_error_codes["0x$HResult"]
        Write-Output "Update $KB failed to install, reporting: $Message"
        Exit 2
    }
    default { Write-Output "Update $KB is not provided by the update server!"; Exit 5 }
}
