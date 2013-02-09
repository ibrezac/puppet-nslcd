# == Class: nslcd
#
# This module manages the nslcd server. More descriptions here
#
# === Parameters
#
# [*ensure*]
#   Controls the software installation
#   Valid values: <tt>present</tt>, <tt>absent</tt>, <tt>purge</tt>
#
# [*service_enable*]
#   Controls if service should be enabled on boot
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*service_status*]
#   Controls service state.
#   Valid values: <tt>running</tt>, <tt>stopped</tt>, <tt>unmanaged</tt>
#
# [*autoupgrade*]
#   If Puppet should upgrade the software automatically
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*autorestart*]
#   If Puppet should restart service on config changes
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*source*]
#   Path to static Puppet file to use
#   Valid values: <tt>puppet:///modules/mymodule/path/to/file.conf</tt>
#
# [*template*]
#   Path to ERB puppet template file to use
#   Valid values: <tt>mymodule/path/to/file.conf.erb</tt>
#
# [*ldap_uri*]
#   LDAP uri to query, multiple servers can be white space separated
#   Valid values: <tt>ldap://127.0.0.1/</tt>
#
# [*ldap_base*]
#   LDAP search base
#   Valid values: <tt>dc=localdomain</tt>
#
# [*ldap_version*]
#   LDAP version number
#   Valid values: <tt>2</tt>, <tt>3</tt>
#
# [*ldap_binddn*]
#   If LDAP server requires a binddn, provide here
#   Valid values: <tt>cn=lookupuser,dc=localdomain</tt>
#
# [*ldap_bindpw*]
#   If LDAP server requires a binddn, provide password to dn here
#   Valid values: <tt>password</tt>
#
# [*ldap_ssl*]
#   If SSL encrypted LDAP should be used
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*ldap_tls_reqcert*]
#   If TLS server certificate should be validated
#   Valid values: <tt>never</tt>, <tt>allow</tt>, <tt>try</tt>, <tt>demand</tt>, <tt>hard</tt>
#
# [*ldap_scope*]
#   Specifies the search scope
#   Valid values: <tt>sub</tt>, <tt>one</tt>, <tt>base</tt>
#
# [*parameters*]
#   Hash variable to pass to nslcd
#   Valid values: hash, ex:  <tt>{ 'option' => 'value' }</tt>
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'nslcd': }
#
# * Uninstalling the software
#   class { 'nslcd': ensure => absent }
#
# * Installing, with service disabled on boot and using custom passwd settings
#   class { 'nslcd:
#     service_enable    => false,
#     parameters_passwd => {
#       'enable-cache'  => 'no'
#     }
#   }
#
# === Supported platforms
#
# This module has been tested on the following platforms
# * Ubuntu LTS 10.04
#
# To add support for other platforms, edit the params.pp file and provide
# settings for that platform.
#
# === Author
#
# Johan Lyheden <johan.lyheden@artificial-solutions.com>
#
class nslcd (  $ensure = $nslcd::params::ensure,
               $service_enable = $nslcd::params::service_enable,
               $service_status = $nslcd::params::service_status,
               $autoupgrade = $nslcd::params::autoupgrade,
               $autorestart = $nslcd::params::autorestart,
               $source = $nslcd::params::source,
               $template = $nslcd::params::template,
               $ldap_uri = $nslcd::params::ldap_uri,
               $ldap_base = $nslcd::params::ldap_base,
               $ldap_version = $nslcd::params::ldap_version,
               $ldap_binddn = $nslcd::params::ldap_binddn,
               $ldap_bindpw = $nslcd::params::ldap_bindpw,
               $ldap_ssl = $nslcd::params::ldap_ssl,
               $ldap_tls_reqcert = $nslcd::params::ldap_tls_reqcert,
               $ldap_scope = $nslcd::params::ldap_scope,
               $parameters = {} ) inherits nslcd::params {

  # Input validation
  validate_re($ensure,[ 'present', 'absent', 'purge' ])
  validate_re($service_status, [ 'running', 'stopped', 'unmanaged' ])
  validate_re($ldap_version, [ '2', '3' ])
  validate_bool($autoupgrade)
  validate_bool($autorestart)
  validate_bool($ldap_ssl)
  validate_hash($parameters)

  # Insert class parameters into hash
  # This simplifies the erb template and makes
  # it less verbose
  $parameters['uri'] = $ldap_uri
  $parameters['base'] = $ldap_base
  $parameters['ldap_version'] = $ldap_version
  $parameters['binddn'] = $ldap_binddn
  $parameters['bindpw'] = $ldap_bindpw
  $parameters['ssl'] = $ldap_ssl
  $parameters['tls_reqcert'] = $ldap_tls_reqcert
  $parameters['scope'] = $ldap_scope

  # 'unmanaged' is an unknown service state
  $service_status_real = $service_status ? {
    'unmanaged' => undef,
    default     => $service_status
  }

  # Manages automatic upgrade behavior
  if $ensure == 'present' and $autoupgrade == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure
  }

  case $ensure {

    # If software should be installed
    present: {
      if $autoupgrade == true {
        Package['nslcd'] { ensure => latest }
      } else {
        Package['nslcd'] { ensure => present }
      }
      if $autorestart == true {
        Service['nslcd/service'] { subscribe => File['nslcd/config'] }
      }
      if $source == undef {
        File['nslcd/config'] { content => template($template) }
      } else {
        File['nslcd/config'] { source => $source }
      }
      File {
        require => Package['nslcd'],
        before  => Service['nslcd/service']
      }
      service { 'nslcd/service':
        ensure  => $service_status_real,
        name    => $nslcd::params::service,
        enable  => $service_enable,
        require => [ Package['nslcd'], File['nslcd/config' ] ]
      }
      file { 'nslcd/config':
        ensure  => present,
        owner   => root,
        group   => $nslcd::params::group,
        mode    => $nslcd::params::config_file_mode,
        path    => $nslcd::params::config_file,
      }
      file { 'nslcd/rundir':
        ensure  => directory,
        owner   => $nslcd::params::user,
        group   => $nslcd::params::group,
        path    => $nslcd::params::run_dir,
        mode    => '0755'
      }
    }
    
    # If software should be uninstalled
    absent,purge: {
      Package['nslcd'] { ensure => $ensure }
    }
    
    # Catch all, should not end up here due to input validation
    default: {
      fail("Unsupported ensure value ${ensure}")
    }
  }
  
  package { 'nslcd':
    name    => $nslcd::params::package
  }

}
