class windows_updates (
  $ensure   = 'enabled',
  $kb = undef,
){
  case $ensure {
    'enabled', 'present': {
      file { 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate':
        ensure             => directory,
        recurse            => true,
        source_permissions => ignore,
        source             => 'puppet:///modules/windows_updates'
      }
      ->
      exec { "Install ${kb}":
        command  => template('windows_updates/install_kb.ps1.erb'),
        provider => 'powershell',
        timeout  => 1200
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
