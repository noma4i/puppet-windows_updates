define windows_updates::kb (
  $ensure   = 'enabled',
  $kb = undef
){
  require windows_updates

  case $ensure {
    'enabled', 'present': {
      exec { "Install ${kb}":
        command  => template('windows_updates/install_kb.ps1.erb'),
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
