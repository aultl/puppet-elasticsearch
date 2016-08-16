# params.pp - Parameters for elasticsearch module
class elasticsearch::params {
  $user_name    = 'es_user'
  $user_uid     = '521'
  $group_name   = 'es_user'
  $group_gid    = '521'
  $home_path    = "/export/home/${user_name}"
  $java_home    = '/opt/jdk8'
  $service_path = '/opt/elasticsearch'
  $data_path    = "${service_path}/data"
  $log_path     = "${service_path}/logs"
  $cert_path    = "${service_path}/certs"
 
}
