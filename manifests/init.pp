# == Class: phpmyadmin
#
# This is the installer/main class for phpmyadmin. This allows you to do a very basic install of phpmyadmin.
# Additionally the class will generate a basic apache config file with some basic permissions for access
#
# === Parameters
# [*enabled*]
#   Default to true. This sets the package as installed or uninstalled and affects the config as well.
# [*manage_apache*]
#   If true, will attempt to install the apache module (default: true)
# [*ip_access_ranges*]
#   True to what it sounds like, this sets the ip ranges which are allowed to access phpmyadmin.
#   These IP ranges can be either a single range or an array. Should be in dotted quad or ipv6
#   notation (ex: 192.168.1.0/255.255.255.0, 192.168.1.10, 2012:db8:1234:ffff:ffff:ffff:ffff:ffff, etc.)
# [*manage_config*]
#   Whether to manage phpMyAdmin's Apache configuration.
# [*use_alias*]
#   Whether to create the standard phpMyAdmin Apache aliases.
# [*preseed_package*]
#   Whether to preconfigure package installation using debconf.
# [*package_name*]
#   The phpMyAdmin package name.
# [*apache_default_config*]
#   Path to the Apache configuration file managed by this module.
# [*apache_name*]
#   Name of the Apache service resource.
#
# === Examples
#
#  class { phpmyadmin:
#    enabled          => true,
#    ip_access_ranges => [ '192.168.1.0/255.255.255.0', '10.30.1.1' ],
#  }
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class phpmyadmin (
  Boolean $enabled                = true,
  Boolean $manage_apache          = true,
  Boolean $manage_config          = true,
  Array[String] $ip_access_ranges = [
    "${facts['networking']['ip']}/${facts['networking']['netmask']}",
  ],
  Boolean $use_alias              = true,
  Boolean $preseed_package        = $phpmyadmin::params::preseed_package,
  String $package_name            = $phpmyadmin::params::package_name,
  String $apache_default_config   = $phpmyadmin::params::apache_default_config,
  String $apache_name             = $phpmyadmin::params::apache_name,
) inherits phpmyadmin::params {
  if $manage_apache and !defined(Class['apache']) {
    class { 'apache':
      mpm_module => 'prefork',
    }

    include apache::mod::php
  }

  $package_ensure = $enabled ? {
    true    => 'present',
    false   => 'absent',
  }

  if $manage_config and $enabled {
    file { $apache_default_config:
      ensure  => file,
      content => template('phpmyadmin/phpMyAdmin.conf.erb'),
      require => Package[$package_name],
      notify  => Service[$apache_name],
    }
  } elsif $manage_config {
    file { $apache_default_config:
      ensure => absent,
    }
  }

  if $preseed_package and $enabled {
    phpmyadmin::debconf { 'reconfigure-webserver':
      selection  => 'phpmyadmin/reconfigure-webserver',
      value_type => 'multiselect',
      value      => 'apache2',
      before     => Package[$package_name],
    }
  }

  ensure_packages(
    [$package_name],
    { ensure => $package_ensure },
  )
}
