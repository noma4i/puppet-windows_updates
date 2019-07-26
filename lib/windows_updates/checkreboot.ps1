$objSystemInfo = New-Object -ComObject "Microsoft.Update.SystemInfo"
([String]$objSystemInfo.RebootRequired).ToLower()