class windows_updates::name (
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
      exec { "Install Updates By Name ${update_name}":
        command  => template('windows_updates/install_by_name.ps1.erb'),
        provider => 'powershell',
        timeout  => 14400
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
