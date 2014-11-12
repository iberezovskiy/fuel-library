# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir = '/etc/zookeeper/conf',
){
  require zookeeper::install

  service { 'zookeeper':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      Package['zookeeper'],
      File["${cfg_dir}/zoo.cfg"]
    ]
  }
  # Package['zookeeperd'] -> Package['zookeeper']
}