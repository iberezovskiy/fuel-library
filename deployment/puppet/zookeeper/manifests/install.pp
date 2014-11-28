# Class: zookeeper::install
#
# This module manages Zookeeper installation
#
# Parameters: None
#
# Actions: None
#
# Requires:
#
# Sample Usage: include zookeeper::install
#
class zookeeper::install(
  $ensure            = present,
  $snap_retain_count = 3,
  $datastore         = '/var/lib/zookeeper',
  $user              = 'zookeeper',
) {

  case $::osfamily {
    'RedHat': {
      $cron_package_name = 'crontabs'
      if !defined(Package['zookeeper']) {
        package { ['zookeeper']:
          ensure => $ensure
        }
      }
      $zookeeper_bin_dir = '/usr/lib/zookeeper/bin'
    }
    'Debian': {
      $cron_package_name = 'cron'
      if !defined(Package['zookeeper']) {
        package { ['zookeeper']:
          ensure => $ensure
        }

        package { ['zookeeperd']: #init.d scripts for zookeeper
          ensure  => $ensure,
          require => Package['zookeeper']
        }
      }
      $zookeeper_bin_dir = '/usr/share/zookeeper/bin'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: \
${::operatingsystem}, module ${module_name} only support osfamily \
RedHat and Debian")
    }
  }

  $cleanup_sh = "$zookeeper_bin_dir/zkCleanup.sh"

  # if !$cleanup_count, then ensure this cron is absent.
  if ($snap_retain_count > 0 and $ensure != 'absent') {
    ensure_packages([$cron_package_name])

    cron { 'zookeeper-cleanup':
        ensure  => present,
        command => "${cleanup_sh} ${datastore} ${snap_retain_count}",
        hour    => 2,
        minute  => 42,
        user    => $user,
        require => Package['zookeeper'],
    }
  }

  file { "/usr/bin/zkCli":
    ensure => 'link',
    target => "$zookeeper_bin_dir/zkCli.sh",
  } ->
  file { "/usr/bin/zkCleanup":
    ensure => 'link',
    target => "$zookeeper_bin_dir/zkCleanup.sh",
  } ->
  file { "/usr/bin/zkServer":
    ensure => 'link',
    target => "$zookeeper_bin_dir/zkServer.sh",
  }
}

