# windows_updates

Puppet module to install selected windows updates or mask of updated etc.

#### How to use

Install specific update by KB number.

```puppet
  windows_updates::kb {'Some cool KB!':
    ensure => 'present',
    kb => 'KB3012199'
  }
````

Install Updates by name or mask. Will install all updates matching `.Net*` mask

```puppet
  windows_updates::list {'.Net Updates':
    ensure => 'present',
    name => '.Net*'
  }
````
