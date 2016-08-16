# node.pp - creats an elasticsearch node
# tribe_list is expected to be a hash in the following format:
# { 'tribename1' => 'clustername1', 'tribename2' => 'clustername2' }
define elasticsearch::node (
  $node_type        = 'default',
  $data_path        = $elasticsearch::params::data_path,
  $log_path         = $elasticsearch::params::log_path,
  $user_name        = $elasticsearch::params::user_name,
  $java_home        = $elasticsearch::params::java_home,
  $http_port        = '9200',
  $transport_port   = '9300',
  $use_iptables     = 'no',
  $listen_https     = false,
  $mlockall         = false,
  $min_master_nodes = '1',
  $client_cert      = '',
  $client_key       = '',
  $cluster_name     = '',
  $cluster_nodes    = '',
  $tribe_list       = '', 
){
  include elasticsearch::params

  $node_name = "${fqdn}"
  
  validate_array_member($node_type, ['master','client','data','tribe','default'])

  if $node_type != 'default' and $node_type != 'tribe' {
    validate_string($cluster_name)
    validate_array($cluster_nodes)
  }

  if $node_type == 'tribe' {
    validate_hash($tribe_list)
  }

  case $node_type {
    'master' : {
      $master = 'true'
      $data   = 'false'
    }
    'client' : {
      $master = 'false'
      $data   = 'false'
    }
    'data' : {
      $master = 'false'
      $data   = 'true'
    }
    'tribe' : {
      $master = 'false'
      $data   = 'false'
    }
    'default' : {
      $master = 'true'
      $data   = 'true'
    }
  }

  if $listen_https {
    validate_string($client_cert)
    validate_string($client_key)

    # install client key
    file { 'es_client_key':
      ensure  => present,
      name    => "${elasticsearch::params::cert_path}/${client_key}",
      source  => "puppet://modules/${module_name}/${client_key}",
      owner   => $elasticsearch::params::user_name,
      group   => $elasticsearch::params::group_name,
      mode    => '640',
      require => File['cert_path'],
    }

    # Install client cert
    file { 'es_config_file':
      ensure  => present,
      name    => "${elasticsearch::params::cert_path}/${client_cert}",
      source  => "puppet://modules/${module_name}/${client_cert}",
      owner   => $elasticsearch::params::user_name,
      group   => $elasticsearch::params::group_name,
      mode    => '640',
      require => File['cert_path'],
    }
  }

  # Configure the service
  file { 'es_config_file':
    ensure  => present,
    name    => "${elasticsearch::params::service_path}/current/config/elasticsearch.yml",
    content => template("${module_name}/elasticsearch.yml.erb"),
    owner   => $elasticsearch::params::user_name,
    group   => $elasticsearch::params::group_name,
  }

  # should we lock memory to prevent swapping?
  if $mlockall {
    # configure ulimit to == unlimited
    #   
  }

  # install an init script
  if $::osfamily == 'RedHat' {
    # Do RedHat/CentOS type stuff
    if $::operatingsystemreleasemajor == '6' {
      # Drop in a SySv Init Script
      file { 'elastic_init_el6':
        ensure  => present,
        name    => "/etc/init.d/elasticsearch",
        content => template("${module_name}/elastic.service"),
        owner   => 'root',
        group   => 'root',
        mode    => '755',
        notify  => Exec['install_elastic_init'],
      }

      exec { 'install_elastic_init' :
        cwd         => $elasticsearch::params::service_path,
        user        => 'root',
        command     => "/sbin/chkconfig --add elasticsearch",
        refreshonly => true,
      }
    } else {
      # Drop in a Systemd Init Script
      file { 'elastic_init_el7':
        ensure  => present,
        name    => "/etc/systemd/system/elasticsearch.service",
        content => template("${module_name}/elastic.service"),
        owner   => 'root',
        group   => 'root',
      }
    }
  } elsif $::osfamily == 'Solaris' {
    # Do Solaris SMF type stuff
  } else {
    # Do nothing ?!?
    notice("Unable to create startup script for ${osfamily} on node: ${fqdn}!")
  }

  # Configure iptables
  if ($use_iptables == 'yes') {
    iptables::rule { 'es_request' :
      action   => 'accept',
      dport    => $http_port,
      chain    => 'RH-Firewall',
      protocol => 'tcp',
      state    => 'new',
    }

    iptables::rule { 'es_transport' :
      action   => 'accept',
      dport    => $transport_port,
      chain    => 'RH-Firewall',
      protocol => 'tcp',
      state    => 'new',
    }
  }
} 
