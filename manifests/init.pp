class windows_updates() {
  file { 'C:\\Program Files\\WindowsPowerShell\\Modules\\PSWindowsUpdate':
    ensure             => directory,
    recurse            => true,
    source_permissions => ignore,
    source             => 'puppet:///modules/windows_updates'
  }->
  file { 'C:\\ProgramData\\InstalledUpdates':
    ensure             => directory,
    recurse            => true,
    source_permissions => ignore
  }
}
