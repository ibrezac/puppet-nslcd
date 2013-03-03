require 'spec_helper'

describe 'nslcd' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu'
  } } 

  context 'with default params' do
    it do should contain_package('nslcd').with(
      'ensure'  => 'present',
      'name'    => 'nslcd'
    ) end
    it do should contain_service('nslcd').with(
      'ensure'    => 'running',
      'enable'    => true,
      'name'      => 'nslcd',
      'subscribe' => 'File[nslcd/config]',
      'source'    => nil,
      'require'   => [ 'Package[nslcd]', 'File[nslcd/config]' ]
    ) end
    it do should contain_file('nslcd/rundir').with(
      'ensure'    => 'directory',
      'owner'     => 'nslcd',
      'group'     => 'nslcd',
      'mode'      => '0755',
      'path'      => '/var/run/nslcd'
    ) end
    it do should contain_file('nslcd/config').with(
      'ensure'    => 'present',
      'owner'     => 'root',
      'group'     => 'nslcd',
      'mode'      => '0640',
      'path'      => '/etc/nslcd.conf'
    ).with_content(/uid nslcd\ngid nslcd\n\n# Configurable parameters\nbase dc=localdomain\nldap_version 3\nssl off\nuri ldap:\/\/127.0.0.1\/\n/)
    end
  end

  context 'with autoupgrade => true' do
    let (:params) { {
      :autoupgrade  => true
    } }
    it do should contain_package('nslcd').with(
      'ensure'  => 'latest',
      'name'    => 'nslcd'
    ) end
  end

  context 'with service_enable => false' do
    let (:params) { {
      :service_enable  => false
    } }
    it do should contain_service('nslcd').with(
      'enable'  => false,
      'name'    => 'nslcd'
    ) end
  end

  context 'with autorestart => false' do
    let (:params) { {
      :autorestart  => false
    } }
    it do should contain_service('nslcd').with(
      'subscribe' => nil,
      'name'      => 'nslcd'
    ) end
  end

  context 'with parameters hash' do
    let (:params) { {
      :parameters => {
        'key1'  => 'value1',
        'akey2' => 'value2',
        'zkey3' => 'value3'
      }
    } }
    it do should contain_file('nslcd/config').with_content(/akey2 value2\nbase dc=localdomain\nkey1 value1\nldap_version 3\nssl off\nuri ldap:\/\/127.0.0.1\/\nzkey3 value3\n/)
    end
  end

  context 'with source => puppet:///modules/mymodule/myfile' do
    let (:params) { {
      :source => 'puppet:///modules/mymodule/myfile'
    } }
    it do should contain_file('nslcd/config').with(
      'content'   => nil,
      'source'    => 'puppet:///modules/mymodule/myfile'
    ) end
  end

  context 'with invalid operatingsystem' do
    let (:facts) { {
      :operatingsystem => 'beos'
    } }
    it do
      expect {
        should contain_class('pam::params')
      }.to raise_error(Puppet::Error, /Unsupported operatingsystem beos/)
    end
  end

end
