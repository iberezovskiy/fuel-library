# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir = '/etc/zookeeper',
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
}
