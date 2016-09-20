# == Class: puppetserver
#
# Module to manage puppetserver
#
class puppetserver (
  $enable_ca                         = true,
  $package_ensure                    = 'installed',
  $package_name                      = ['puppetserver'],
  $service_enable                    = true,
  $service_ensure                    = 'running',
  $service_name                      = 'puppetserver',
  $java_args                         = undef,
  $bootstrap_settings                = undef,
  $bootstrap_settings_hiera_merge    = false,
  $puppetserver_settings             = undef,
  $puppetserver_settings_hiera_merge = false,
  $webserver_settings                = undef,
  $webserver_settings_hiera_merge    = false,
) {

  validate_re($package_ensure, '^(installed|present|absent|(\d+)\.(\d+)\.(\d+))$', "puppetserver::package_ensure must be one of <installed>, <present>, <absent>, or a semantic version number but it is set to ${package_ensure}")
  validate_re($service_ensure, '^(running|stopped)$', "puppetserver::service_ensure must be one of <running> or <stopped> but it is set to ${service_ensure}")
  if is_string($service_name) == false { fail('puppetserver::service_name is not a string.') }

  case $service_enable {
    true, 'true':   { $service_enable_bool = true } # lint:ignore:quoted_booleans
    false, 'false': { $service_enable_bool = false } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::service_enable is not a boolean.') }
  }

  case type3x($package_name) {
    'array':  { $package_name_array = $package_name }
    'string': { $package_name_array = any2array($package_name) }
    default:  { fail('puppetserver::package_name is not an array nor a string.') }
  }

  package { $package_name_array:
    ensure => $package_ensure,
    before => Service[$service_name],
  }

  include ::puppetserver::config

  if defined(Service[$service_name]) == false {
    service { $service_name:
      ensure => $service_ensure,
      enable => $service_enable_bool,
    }
  }

  Package[$package_name_array] -> Class[puppetserver::config] ~> Service[$service_name]
}
