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
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
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
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: \
${::operatingsystem}, module ${module_name} only support osfamily \
RedHat and Debian")
    }
  }

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
}

