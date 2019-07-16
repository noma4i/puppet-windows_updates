define windows_updates::list (
  $ensure      = 'enabled',
  $name_mask   = undef,
  $dry_run     = false,
  $maintwindow = undef
){
  require windows_updates

  case $ensure {
    'enabled', 'present': {
      if $dry_run == false{
        exec { "Install Updates By Name ${name_mask}":
          command  => template('windows_updates/install_by_title.ps1.erb'),
          provider => 'powershell',
          timeout  => 14400,
          schedule => $maintwindow
        }
      } else {
        exec { "Dry-Run Updates By Name ${name_mask}":
          command  => template('windows_updates/dry_run_updates.ps1.erb'),
          provider => 'powershell',
          timeout  => 14400,
        }
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
