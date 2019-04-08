$objSystemInfo = New-Object -ComObject "Microsoft.Update.SystemInfo"
$objSystemInfo.RebootRequired.ToLower()