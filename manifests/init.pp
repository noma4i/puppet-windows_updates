class windows_updates (
  $ensure   = 'enabled',
  $kb = undef,
){
  case $ensure {
    'enabled', 'present': {
      exec { 'Install PSModule to manage Windows Updates':
        command  => template('windows_updates/install_psupdates.ps1.erb'),
        provider => 'powershell',
        onlyif   => 'if ((Test-Path -Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate") -eq $False) { exit 0 } else { exit 1 }',
        timeout  => 600
      }
      # ->
      # exec { "Install ${kb}":
      #   command  => template('windows_updates/install_kb.ps1.erb'),
      #   provider => 'powershell',
      #   timeout  => 600
      # }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
