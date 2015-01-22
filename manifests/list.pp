define windows_updates::list (
  $ensure   = 'enabled',
  $name = undef
){
  require windows_updates

  case $ensure {
    'enabled', 'present': {
      exec { "Install Updates By Name ${update_name}":
        command  => template('windows_updates/install_by_title.ps1.erb'),
        provider => 'powershell',
        timeout  => 14400
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
