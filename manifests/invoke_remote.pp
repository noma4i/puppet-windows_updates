define windows_updates::invoke_remote (
  $ensure   = 'enabled',
  $kb = undef
){
  require windows_updates

  case $ensure {
    'enabled', 'present': {
      exec { "Install ${kb}":
        command  => template('windows_updates/invoke_remote.ps1.erb'),
        creates  => "C:\\ProgramData\\InstalledUpdates\\${kb}.flg",
        provider => 'powershell',
        timeout  => 1800
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
