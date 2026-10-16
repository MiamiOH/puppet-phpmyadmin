#Simple class to validate and seed the correct package selection for debian based systems
# === Parameters
#
# [*selection*]
#   The debconf configuration key to set.
# [*value_type*]
#   The debconf value type, such as string or boolean.
# [*value*]
#   The value to assign to the debconf configuration key.
# [*debconf_package*]
#   The package providing the debconf utilities.
define phpmyadmin::debconf (
  Optional[String] $selection       = undef,
  String $value_type                = 'string',
  Optional[String] $value           = undef,
  String $debconf_package           = $phpmyadmin::params::debconf_package,
) {
  include phpmyadmin::params

  #Install debconf package as needed
  ensure_packages([$debconf_package])

  #Run the actual debconf selector
  exec { $name:
    command => "/bin/echo debconf ${selection} ${value_type} ${value} | /usr/bin/debconf-set-selections",
    require => Package[$debconf_package],
    unless  => "/usr/bin/debconf-get-selections | /bin/egrep 'debconf[[:space:]]+${selection}+[[:space:]]+${value_type}+[[:space:]]+${value}'",
  }
}
