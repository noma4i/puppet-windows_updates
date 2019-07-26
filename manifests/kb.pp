define windows_updates::kb (
  $ensure      = 'enabled',
  $kb          = $name,
  $maintwindow = undef
){
  require windows_updates

  case $ensure {
    'enabled', 'present': {
      case $kb {
        'KB890830', 'kb890830': {
          #Don't skip this recurring monthly update (Malicious Software Removal Tool)
          exec { "Install ${kb}":
            command   => template('windows_updates/install_kb.ps1.erb'),
            provider  => 'powershell',
            timeout   => 14400,
            logoutput => true,
            schedule  => $maintwindow
          }
        }
        default: {
          #Run update if it hasn't successfully run before
          exec { "Install ${kb}":
            command   => template('windows_updates/install_kb.ps1.erb'),
            creates   => "C:\\ProgramData\\InstalledUpdates\\${kb}.flg",
            provider  => 'powershell',
            timeout   => 14400,
            logoutput => true,
            schedule  => $maintwindow
          }
        }
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
