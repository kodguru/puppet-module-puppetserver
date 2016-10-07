#
class puppetserver::config(
  $bootstrap_cfg                     = '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
  $configdir                         = '/etc/puppetlabs/puppetserver/conf.d',
  $enable_ca                         = $::puppetserver::enable_ca,
  $enable_tmpfix                    = true,
  $java_args                         = $::puppetserver::java_args,
  $bootstrap_settings                = $::puppetserver::bootstrap_settings,
  $bootstrap_settings_hiera_merge    = $::puppetserver::bootstrap_settings_hiera_merge,
  $puppetserver_settings             = $::puppetserver::puppetserver_settings,
  $puppetserver_settings_hiera_merge = $::puppetserver::puppetserver_settings_hiera_merge,
  $webserver_settings                = $::puppetserver::webserver_settings,
  $webserver_settings_hiera_merge    = $::puppetserver::webserver_settings_hiera_merge,

) inherits puppetserver {

  # variable preparations
  case $bootstrap_settings_hiera_merge {
    true, 'true':   { $bootstrap_settings_real = hiera_hash(puppetserver::bootstrap_settings, {} ) } # lint:ignore:quoted_booleans
    false, 'false': { $bootstrap_settings_real = $bootstrap_settings } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::bootstrap_settings_hiera_merge is not a boolean.') }
  }

  case $puppetserver_settings_hiera_merge {
    true, 'true':   { $puppetserver_settings_real = hiera_hash(puppetserver::puppetserver_settings, {} ) } # lint:ignore:quoted_booleans
    false, 'false': { $puppetserver_settings_real = $puppetserver_settings } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::puppetserver_settings_hiera_merge is not a boolean.') }
  }

  case $webserver_settings_hiera_merge {
    true, 'true':   { $webserver_settings_real = hiera_hash(puppetserver::webserver_settings, {} ) } # lint:ignore:quoted_booleans
    false, 'false': { $webserver_settings_real = $webserver_settings } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::webserver_settings_hiera_merge is not a boolean.') }
  }

  case $enable_ca {
    true, 'true':   { $enable_ca_bool = true } # lint:ignore:quoted_booleans
    false, 'false': { $enable_ca_bool = false } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::enable_ca is not a boolean.') }
  }

  $enable_tmpfix_real = str2bool($enable_tmpfix)

  $_ca_service = 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service'
  $_ca_disable = 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service'

  validate_absolute_path(
    $bootstrap_cfg,
    $configdir,
  )

  validate_hash($java_args)

  if $enable_ca_bool == true {
    $bootstrap_ca_defaults = {
      'ca.certificate-authority-service' => {
        'line'  => $_ca_service,
        'match' => $_ca_service,
      },
      'ca.certificate-authority-disabled-service' => {
        'line'  => "#${_ca_disable}",
        'match' => $_ca_disable,
      },
    }
  } else {
    $bootstrap_ca_defaults = {
      'ca.certificate-authority-service' => {
        'line'  => "#${_ca_service}",
        'match' => $_ca_service,
      },
      'ca.certificate-authority-disabled-service' => {
        'line'  => $_ca_disable,
        'match' => $_ca_disable,
      },
    }
  }

  if $enable_tmpfix_real == true {
    file { '/var/lib/puppet':
      ensure  => 'directory',
    }
    file { '/var/lib/puppet/tmp':
      ensure  => 'directory',
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0755',
      require => File['/var/lib/puppet'],
    }
    $java_args_real = merge($java_args, { '-D' => { 'value' => 'java.io.tmpdir=/var/lib/puppet/tmp' } })
  }
  else {
    $java_args_real = $java_args
  }

  if $java_args_real != undef {
    $java_args_defaults = {
      'notify' => Service[$::puppetserver::service_name],
    }
    create_resources('puppetserver::config::java_arg', $java_args_real, $java_args_defaults)
  }

  if $bootstrap_settings_real != undef {
    validate_hash($bootstrap_settings_real)
    $_bootstrap_settings = merge($bootstrap_ca_defaults, $bootstrap_settings_real)
  } else {
    $_bootstrap_settings = $bootstrap_ca_defaults
  }
  $bootstrap_defaults = {
    'path' => $bootstrap_cfg,
  }
  create_resources(file_line, $_bootstrap_settings, $bootstrap_defaults)

  if $puppetserver_settings_real {
    validate_hash($puppetserver_settings_real)
    $puppetserver_defaults = {
      'ensure' => 'present',
      'path'   => "${configdir}/puppetserver.conf",
    }
    create_resources('puppetserver::config::hocon', $puppetserver_settings_real, $puppetserver_defaults)
  }

  if $webserver_settings_real != undef {
    validate_hash($webserver_settings_real)
    $webserver_defaults = {
      'ensure' => 'present',
      'path'   => "${configdir}/webserver.conf",
    }
    create_resources('puppetserver::config::hocon', $webserver_settings_real, $webserver_defaults)
  }
}
