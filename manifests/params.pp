# == Class: TEMPLATE::params
#
# This class is only used to set variables
#
class TEMPLATE::params {

  $ensure = present
  $service_enable = true
  $service_status = running
  $autoupgrade = false
  $autorestart = true
  $source = undef
  $template = 'TEMPLATE/TEMPLATE.conf.erb'
  $source_dir = undef
  $source_dir_purge = undef
  
  # This mandates which distributions are supported
  # To add support for other distributions simply add
  # a matching regex line to the operatingsystem fact
  case $::lsbdistcodename {
    lucid: {
      $package = 'TEMPLATE'
      $service = 'TEMPLATE'
      $config_file = '/etc/TEMPLATE.conf'
    }
    default: {
      fail("Unsupported distribution ${::lsbdistcodename}")
    }
  }

}
