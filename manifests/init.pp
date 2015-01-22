class windows_updates (){
  file { 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\Modules\\PSWindowsUpdate':
    ensure             => directory,
    recurse            => true,
    source_permissions => ignore,
    source             => 'puppet:///modules/windows_updates'
  }
}