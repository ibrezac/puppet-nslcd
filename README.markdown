# Module: nslcd

This is the Puppet module for nslcd - local LDAP name service daemon.
Nslcd is a daemon that will do LDAP queries for local processes based
on a simple configuration file.

## Dependencies

* puppet-stdlib: https://github.com/puppetlabs/puppetlabs-stdlib

## Usage: nslcd

You can install nslcd with the default by including the class

	inclue nslcd

However, to be of any use its necessary to configure the LDAP service
that should be queried.

	class { 'nslcd':
		ldap_uri         => 'ldap://my.server.com',
		ldap_base        => 'dc=server,dc=com',
		ldap_binddn      => 'cn=reader,ou=users,dc=server,dc=com',
		ldap_bindpw      => 's3cret',
		ldap_ssl         => true,
		ldap_tls_reqcert => 'never',
		ldap_scope       => 'sub',
		parameters       => {
			'custom_parameter' => 'value'
		}
	}

