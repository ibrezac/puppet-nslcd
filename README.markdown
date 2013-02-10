# Module: nslcd

This is the Puppet module for nslcd - local LDAP name service daemon.
Nslcd is a daemon that will do LDAP queries for local processes based
on a simple configuration file.

## Dependencies

* puppet-stdlib: https://github.com/puppetlabs/puppetlabs-stdlib

## Usage: nslcd

You can install nslcd with the default by including the class

	include nslcd

However, to be of any use it's necessary to configure the LDAP service
that should be queried. The following example configures authentication
to Active Directory over LDAPS:

	class { 'nslcd':
		ldap_uri         => 'ldaps://my.server.com',
		ldap_base        => 'dc=server,dc=com',
		ldap_binddn      => 'cn=reader,ou=users,dc=server,dc=com',
		ldap_bindpw      => 's3cret',
		ldap_ssl         => true,
		ldap_tls_reqcert => 'never',
		ldap_scope       => 'sub',
		parameters       => {
			'filter passwd'             => '(&(objectClass=user)(!(objectClass=computer))(uidNumber=*)(unixHomeDirectory=*))',
			'filter shadow'             => '(&(objectClass=user)(!(objectClass=computer))(uidNumber=*)(unixHomeDirectory=*))',
			'filter group'              => '(objectClass=group)',
			'map passwd uid'            => 'sAMAccountName',
			'map passwd uidnumber'      => 'uidNumber',
			'map passwd homedirectory'  => 'unixHomeDirectory',
			'map passwd loginshell'     => 'loginShell',
			'map passwd gecos'          => 'displayName',
			'map shadow uid'            => 'sAMAccountName',
			'map group uniqueMember'    => 'member'
		}
	}

