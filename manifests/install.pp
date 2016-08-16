# install.pp - install the elasticsearch server
class elasticsearch::install inherits elasticsearch {
  include jtv_root::params
  # Create group
  group { 'es_group' :
    ensure => present,
    name   => $elasticsearch::params::group_name,
    gid    => $elasticsearch::params::user_gid,
  }

  # Create user 
  user { 'user_es':
    name       => $elasticsearch::params::user_name,
    comment    => $elasticsearch::params::user_gcos,
    home       => $elasticsearch::params::home_path,
    managehome => true,
    ensure     => present,
    shell      => '/bin/bash',
    uid        => $elasticsearch::params::user_uid,
    gid        => $elasticsearch::params::user_gid,
    membership => 'minimum',
  }

  # create service home 
  file { 'es_service_path' :
    ensure => directory,
    name   => $elasticsearch::params::service_path,
    owner  => $elasticsearch::params::user_name,
    group  => $elasticsearch::params::group_name,
    mode   => '755',
  }

  # create data directory
  file { 'es_data_path' :
    ensure  => directory,
    name    => $elasticsearch::params::data_path,
    owner   => $elasticsearch::params::user_name,
    group   => $elasticsearch::params::group_name,
    mode    => '755',
    require => File['es_service_path'],
  }

  # create log directory
  file { 'es_log_path' :
    ensure  => directory,
    name    => $elasticsearch::params::log_path,
    owner   => $elasticsearch::params::user_name,
    group   => $elasticsearch::params::group_name,
    mode    => '755',
    require => File['es_service_path'],
  }

  # create cert directory
  file { 'es_cert_path' :
    ensure  => directory,
    name    => $elasticsearch::params::cert_path,
    owner   => $elasticsearch::params::user_name,
    group   => $elasticsearch::params::group_name,
    mode    => '755',
    require => File['es_service_path'],
  }

  # Install elasticsearch package
  package { 'elasticsearch' :
    ensure  => present,
    require => [ User['user_es'], Repo['inhouse-apps'], File['es_service_path'] ]
  }

}
