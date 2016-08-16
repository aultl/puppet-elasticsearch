# config.pp - class to configure system variables for elasticsearch
class elasticsearch::config inherits elasticsearch {
  # Configure sudo 
  sudo::user_rule { 'softeng_elasticsearch' :
    user_list => '%softeng',
    runas     => $user_name,
    command   => 'ALL',
  }

  # can user remotely login?
  if ( $allow_login ) {
    jtv_access::entry { 'es_user' :
      user  => $elasticsearch::params::user_name,
      login => true,
    }
  }
}
                                                                
