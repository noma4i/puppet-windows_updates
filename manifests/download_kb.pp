define windows_updates::download_kb (
  $ensure      = 'enabled',
  $kb          = $name
){
  require windows_updates

  case $ensure {
    'enabled', 'present': {
      exec { "Download ${kb}":
        command   => template('windows_updates/download_kb.ps1.erb'),
        creates   => "C:\\ProgramData\\InstalledUpdates\\${kb}.dld",
        provider  => 'powershell',
        timeout   => 14400,
        logoutput => true
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
