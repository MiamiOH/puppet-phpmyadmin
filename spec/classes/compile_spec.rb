require 'spec_helper'

describe 'phpmyadmin' do
  context 'on RedHat' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            major: '7',
            full: '7.9',
          },
        },
        networking: {
          ip: '127.0.0.1',
          netmask: '255.0.0.0',
          fqdn: 'localhost',
        },
        path: '/usr/bin:/bin',
        puppetversion: Puppet.version,
        facterversion: Facter.version,
      }
    end

    it { is_expected.to compile }

    it do
      is_expected.to contain_package('phpMyAdmin').with(
        ensure: 'installed',
      )
    end

    it do
      is_expected.to contain_file('/etc/httpd/conf.d/phpMyAdmin.conf').with(
        ensure: 'file',
        require: 'Package[phpMyAdmin]',
      )
    end
  end

  context 'on Debian' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name: 'Debian',
          release: {
            major: '12',
            full: '12',
          },
        },
        networking: {
          ip: '127.0.0.1',
          netmask: '255.0.0.0',
          fqdn: 'localhost',
        },
        path: '/usr/bin:/bin',
        puppetversion: Puppet.version,
        facterversion: Facter.version,
      }
    end

    it { is_expected.to compile }

    it do
      is_expected.to contain_package('phpmyadmin').with(
        ensure: 'installed',
      )
    end

    it do
      is_expected.to contain_package('debconf-utils').with(
        ensure: 'installed',
      )
    end

    it do
      is_expected.to contain_file('/etc/apache2/conf.d/phpmyadmin.conf').with(
        ensure: 'file',
        require: 'Package[phpmyadmin]',
      )
    end

    it do
      is_expected.to contain_exec('reconfigure-webserver').with(
        require: 'Package[debconf-utils]',
      )
    end

    it do
      is_expected.to contain_phpmyadmin__debconf('reconfigure-webserver').with(
        selection: 'phpmyadmin/reconfigure-webserver',
        value_type: 'multiselect',
        value: 'apache2',
      )
    end
  end
end