# Installs/configures the ceilometer central agent
#
# == Parameters
#  [*enabled*]
#    Should the service be enabled. Optional. Defauls to true
#
class ceilometer::agent::central (
  $enabled          = true,
) {

  include ceilometer::params

  Ceilometer_config<||> ~> Service['ceilometer-agent-central']

  Exec['pip-deps'] -> Package['ceilometer-agent-central'] -> Service['ceilometer-agent-central']

  exec { 'pip-deps':
    command   => '/usr/bin/pip install redis && /usr/bin/pip install zake && /usr/bin/pip install tooz',
    logoutput => on_failure,
  }

  package { 'ceilometer-agent-central':
    ensure => installed,
    name   => $::ceilometer::params::agent_central_package_name,
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  Package['ceilometer-common'] -> Service['ceilometer-agent-central']
  service { 'ceilometer-agent-central':
    ensure     => $service_ensure,
    name       => $::ceilometer::params::agent_central_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
  }

}
