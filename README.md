# windows_updates

Puppet module to install selected windows updates or mask of updates etc.

#### Cavets

You may need to use `puppet module install --ignore-dependencies` as powershell may present in your modules

#### How to use

Install specific update by KB number.

```puppet
  windows_updates::kb {'KB3012199':
    ensure => 'present'
  }
````
 or
```puppet
  windows_updates::kb {'Some custom description':
    ensure => 'present',
    kb     => 'KB3012199'
  }
````

Install specific update by KB number in a maintenance window.

```puppet
  windows_updates::kb {'KB3012199':
    ensure      => 'present',
    maintwindow => 'patch_window'
  }
  schedule { 'patch_window':
    range   => '01:00 - 03:00',
    weekday => 'Saturday',
    repeat  => 1
  }
````

Install Updates by name or mask. Will install all updates matching `.Net*` mask

```puppet
  windows_updates::list {'.Net Updates':
    ensure    => 'present',
    name_mask => '.Net*'
  }
````

If you are not sure what updates go with name you set - use `dry_run` option and point it to output file.

```puppet
  windows_updates::list {'.Net Updates':
    ensure    => 'present',
    dry_run   => 'C:\\what_will_be_installed.txt'
    name_mask => '.Net*'
  }
````

In this case your `what_will_be_installed.txt` will look like:

```csv
  ComputerName Status KB          Size Title
  ------------ ------ --          ---- -----
  WIN-H7VQ4... ------ KB2931358 322 KB Security Update for Microsoft .NET Frame...
  WIN-H7VQ4... ------ KB2931366 584 KB Security Update for Microsoft .NET Frame...
  WIN-H7VQ4... ------ KB2961851  15 MB Security Update for Internet Explorer 11...
  WIN-H7VQ4... ------ KB2934520  72 MB Microsoft .NET Framework 4.5.2 for Windo...
```

Install an update from within a WinRM remote session. Because wusa.exe cannot be used over WinRM directly, and `Invoke-WUInstall.ps1` works around this by scheduling a task to actually install the update.

```puppet
  windows_updates::invoke_remote {'Some cool KB!':
    ensure => 'present',
    kb => 'KB3012199'
  }
```

Alternatively, you can use the the `windows_updates::install_kb` task, which auto-detects when it's running over WinRM and switches to task scheduling to still be able to install the update. For this to work inside of Puppet Enterprise, you need to be running at least PE 2019.0 or higher. If you're on an older version of PE and want to use this task, use Bolt instead.