[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)] [String]  $kb,
    [Parameter(Mandatory = $True)] [Boolean] $restart,
    [Parameter(Mandatory = $True)] [String]  $_installdir
)

$Trackingpath = "$Env:ProgramData\InstalledUpdates"
$ProgressPreference = 'SilentlyContinue'
$ErrCodesFile = "$_installdir/windows_updates/lib/windows_updates/errorcodes.txt"
$all_error_codes = Get-Content -raw -Path $ErrCodesFile | ConvertFrom-StringData

if (!(Test-Path -Path $Trackingpath)){
    New-Item -ItemType directory -Path $Trackingpath -Force | Out-Null
}

if ((Get-Content "$Trackingpath\$KB.flg" -ErrorAction SilentlyContinue) -eq "Installed") {
    Write-Host "Update $KB is already installed, skipping installation..."
    Exit 0
}

Import-Module -Name "$_installdir/windows_updates/files/PSWindowsUpdate"
if (Get-WindowsUpdate -KBArticleID "$KB") {
    Write-Host "Update $KB is available on the update server, proceeding with installation..."
} Else {
    Write-Host "Update $KB is not provided by the update server!"
    Exit 5
}

if ($PSSenderInfo){
    # We are running in a WinRM session, can't install Windows Updates directly
    $User = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Role = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    if (!$Role){
        Write-Host "To install updates, the account used to connect over WinRM must have administrative permissions."
        Exit 1
    }
    Write-Host "Running via WinRM: Creating scheduled task to install update $kb"
    [String]$TaskName = "PSWindowsUpdate"
    [String]$Script = "Import-Module -Name '$_installdir/windows_updates/files/PSWindowsUpdate'; Get-WindowsUpdate -KBArticleID '$KB' -Install -AcceptAll -IgnoreReboot"
  
    $Scheduler = New-Object -ComObject Schedule.Service
    $Task = $Scheduler.NewTask(0)
  
    $RegistrationInfo = $Task.RegistrationInfo
    $RegistrationInfo.Description = $TaskName
    $RegistrationInfo.Author = $User.Name
  
    $Settings = $Task.Settings
    $Settings.Enabled = $True
    $Settings.StartWhenAvailable = $True
    $Settings.Hidden = $False
  
    $Action = $Task.Actions.Create(0)
    $Action.Path = "powershell"
    $Action.Arguments = "-Command ""$Script"""
    
    $Task.Principal.RunLevel = 1
  
    $Scheduler.Connect('localhost')
    $RootFolder = $Scheduler.GetFolder("\")
    if ($Scheduler.GetRunningTasks(0) | Where-Object {$_.Name -eq $TaskName}) {
        Write-Host "A PSWindowsUpdate scheduled task is already running, aborting creation of new scheduled task to install $KB"
        Exit 1
    }
    $RootFolder.RegisterTaskDefinition($TaskName, $Task, 6, "SYSTEM", $Null, 1) | Out-Null
    $RootFolder.GetTask($TaskName).Run(0) | Out-Null
    
    $timeout = 14400 # seconds
    $timer =  [Diagnostics.Stopwatch]::StartNew()
    Write-Host "Waiting on PSWindowsUpdate scheduled task to complete..."
    while (($RootFolder.GetTask($TaskName).State -ne 3) -and ($timer.Elapsed.TotalSeconds -lt $timeout)) {    
        Start-Sleep -Seconds 10
    }
    $timer.Stop()
    if ($RootFolder.GetTask($TaskName).State -eq 3) {
        if ($RootFolder.GetTask($TaskName).LastTaskResult -eq 0) {
            Write-Host "Installation of $KB took $([int]$timer.Elapsed.TotalSeconds) seconds"
            $RootFolder.DeleteTask($TaskName,0)
        } Else {
            Write-Host "Installation of $KB seems to have failed, the scheduled task exited with errorcode $($RootFolder.GetTask($TaskName).LastTaskResult)"
            $RootFolder.DeleteTask($TaskName,0)
            Exit 1
        }
    } Else {
        Write-Host "Timeout waiting for PSWindowsUpdate scheduled task to complete. The task will keep running in the background, please check it manually."
        Exit 0
    }
} Else {
    # Not running in a WinRM session, we can install Windows Updates directly
    Get-WindowsUpdate -KBArticleID "$KB" -Install -AcceptAll -IgnoreReboot
    Start-Sleep 10
}

$update = Get-WUHistory | Where-Object KB -eq $KB | Sort-Object Date -Descending | Select-Object -First 1
switch -regex ($update.Result) {
    'Succeeded' {
        Set-Content "$Trackingpath\$KB.flg" "Installed"
        if ($restart) {
            Write-Host "Restart parameter enabled, restarting node in 30 seconds"
            & shutdown -r -t 30
        }
    }
    'SucceededWithErrors|InProgress' {
        $HResult = [Convert]::ToString($update.HResult, 16)
        $Message = $all_error_codes["0x$HResult"]
        Write-Host "Update $KB was installed but reported (likely reboot needed): $Message"
        Set-Content "$Trackingpath\$KB.flg" "Installed"
        if ($restart) {
            Write-Host "Restart parameter enabled, restarting node in 30 seconds"
            & shutdown -r -t 30
        }
    }
    'Failed' {
        $HResult = [Convert]::ToString($update.HResult, 16)
        $Message = $all_error_codes["0x$HResult"]
        Write-Host "Update $KB failed to install, reporting: $Message"
        Exit 2
    }
    default {
        Write-Host "Could not find update $KB in the Windows Update History, it seems installation has not succeeded!"
        Exit 5
    }
}