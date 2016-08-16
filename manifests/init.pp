# init.pp - Entry point for elasticsearch module
class elasticsearch (
  $allow_login = false,
) inherits elasticsearch::params {

  anchor { 'elasticsearch::begin': }
  -> class { '::elasticsearch::install': }
  ~> class { '::elasticsearch::config': }
  -> anchor { 'elasticsearch::end': }

}
