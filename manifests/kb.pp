define windows_updates::kb (
  $ensure   = 'enabled',
  $kb = undef
){
  include windows_updates
  case $ensure {
    'enabled', 'present': {
      file { 'C:\\ProgramData\\InstalledUpdates':
        ensure             => directory,
        recurse            => true,
        source_permissions => ignore
      }->
      exec { "Install ${kb}":
        command  => template('windows_updates/install_kb.ps1.erb'),
        creates  => "C:\\ProgramData\\InstalledUpdates\\${kb}.flg",
        provider => 'powershell',
        timeout  => 1200
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
