class windows_updates (
  $ensure   = 'enabled',
  $kb = undef,
  $update_name = undef,
){
  case $ensure {
    'enabled', 'present': {
      file { 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\Modules\\PSWindowsUpdate':
        ensure             => directory,
        recurse            => true,
        source_permissions => ignore,
        source             => 'puppet:///modules/windows_updates'
      }->
      file { 'C:\\ProgramData\\InstalledUpdates':
        ensure             => directory,
        recurse            => true,
        alias              => "win-dir-ready",
        source_permissions => ignore
      }
      if $kb != undef {
        exec { "Install ${kb}":
          command  => template('windows_updates/install_kb.ps1.erb'),
          creates  => "C:\\ProgramData\\InstalledUpdates\\${kb}.flg",
          require  => "win-dir-ready",
          provider => 'powershell',
          timeout  => 1200
        }
      }
      if $update_name != undef {
        exec { "Install Updates By Name ${update_name}":
          command  => template('windows_updates/install_by_name.ps1.erb'),
          require  => "win-dir-ready",
          provider => 'powershell',
          timeout  => 1200
        }
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
