Facter.add('updates_reboot_needed') do
  confine kernel: 'windows'
  setcode do
    sysroot = ENV['SystemRoot']
    powershell = "#{sysroot}\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
    # get the script path relative to facter Ruby program
    script_file = File.join(
      File.expand_path(File.dirname(__FILE__)),
      '..',
      'windows_updates',
      'checkreboot.ps1',
    )
    Facter::Util::Resolution.exec("#{powershell} -ExecutionPolicy Unrestricted -File #{script_file}").to_s == 'true'
  end
end
