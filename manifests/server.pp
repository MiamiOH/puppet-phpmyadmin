# == Class: phpmyadmin::server
#
# This class allows you to instantiate a server profile for phpmyadmin.
# Without this class your phpmyadmin installation can't actually do much of anything.
# You can use a defined resource for each server entry or use resource collection to build
#
# === Parameters
# [*blowfish_key*]
#   Defaults to a combination of the host and ipaddress fields for the server.
#   You can, and probably should change this to something better.
# [*properties_iconic*]
#   Use icons instead of text for the table display of a database (TRUE|FALSE|'both')
# [*absolute_uri*]
#   Defines the URL under which phpMyAdmin is accessible from the users browser.
#   Complete the variable below with the full URL in the style of <schema>://<server>[:<port>][/<path>] - like http://example.com:8080/phpMyAdmin/. Usually needed for a Reverse Proxy
# [*resource_collect*]
#   Whether to collect exported server-node resources for this server group.
# [*config_file*]
#   Absolute path to the generated phpMyAdmin configuration file.
# [*data_dir*]
#   Absolute path to the phpMyAdmin data directory.
# [*apache_group*]
#   Group that Apache uses to access phpMyAdmin files.
# [*package_name*]
#   Name of the phpMyAdmin package.
#
# === Examples
#
#  phpmyadmin::server {
#    blowfish_key => 'Lho1ih3oi5hoIHAOHHOh1oh5$13@#',
#    resource_collect => false,
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
define phpmyadmin::server (
  String $blowfish_key      = md5("${facts['networking']['fqdn']}${facts['networking']['ip']}"),
  Boolean $resource_collect = true,
  String $properties_iconic = 'FALSE',
  String $absolute_uri      = "http://${facts['networking']['fqdn']}/phpmyadmin/",
  Stdlib::Absolutepath $config_file       = $phpmyadmin::params::config_file,
  Stdlib::Absolutepath $data_dir          = $phpmyadmin::params::data_dir,
  String $apache_group      = $phpmyadmin::params::apache_group,
  String $package_name      = $phpmyadmin::params::package_name,
) {
  include phpmyadmin::params

  #Start by generating the config file using a template file
  concat { $config_file:
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Package[$package_name],
  }
  -> file { "${data_dir}/blowfish_secret.inc.php":
    ensure  => 'file',
    owner   => 'root',
    group   => $apache_group,
    mode    => '0640',
    content => template('phpmyadmin/blowfish_secret.inc.php.erb'),
  }

  #Default header
  concat::fragment { '00_phpmyadmin_header':
    target  => $config_file,
    order   => '01',
    content => template('phpmyadmin/config_header.inc.php.erb'),
  }

  #Gather all server node resources
  if $resource_collect == true {
    Phpmyadmin::Servernode <<| server_group == $name |>> {
      target => $config_file,
    }
  }

  #Footer for the phpmyadmin config
  concat::fragment { '255_phpmyadmin_footer':
    target  => $config_file,
    order   => '255',
    content => template('phpmyadmin/config_footer.inc.php.erb'),
  }
}
