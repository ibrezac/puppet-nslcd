# == Class: nslcd::params
#
# This class is only used to set variables
#
class nslcd::params {

  $ensure = present
  $service_enable = true
  $service_status = running
  $autoupgrade = false
  $autorestart = true
  $source = undef
  $template = 'nslcd/nslcd.conf.erb'
  $source_dir = undef
  $source_dir_purge = undef

  $ldap_uri = 'ldap://127.0.0.1/'
  $ldap_base = 'dc=localdomain'
  $ldap_version = '3'
  $ldap_binddn = undef
  $ldap_bindpw = undef
  $ldap_ssl = undef
  $ldap_tls_reqcert = undef
  $ldap_scope = undef

  # This mandates which distributions are supported
  # To add support for other distributions simply add
  # a matching regex line to the lsbdistcodename fact
  case $::lsbdistcodename {
    lucid: {
      $user = 'nslcd'
      $group = 'nslcd'
      $package = 'nslcd'
      $service = 'nslcd'
      $config_file = '/etc/nslcd.conf'
      $config_file_mode = '0640'
      $run_dir = '/var/run/nslcd'
    }
    default: {
      fail("Unsupported distribution ${::lsbdistcodename}")
    }
  }

}
