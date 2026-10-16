require 'spec_helper'

describe 'phpmyadmin::server', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let :pre_condition do
        [
          'package { "foobar": }',
        ]
      end

      let(:title) { 'barfoo' }

      let :params do
        {
          config_file: '/foobar',
          data_dir: '/foobar',
          apache_group: 'foobar',
          package_name: 'foobar'
        }
      end

      context 'compile' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('phpmyadmin::params') }

        it { is_expected.to contain_concat('/foobar') }

        it {
          is_expected.to contain_concat__fragment('00_phpmyadmin_header').with(
          'target' => '/foobar',
          'order'  => '01',
        )
        }

        it {
          is_expected.to contain_concat__fragment('255_phpmyadmin_footer').with(
          'target' => '/foobar',
          'order'  => '255',
        )
        }

        it {
          is_expected.to contain_file('/foobar/blowfish_secret.inc.php').with(
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'foobar',
          'mode'    => '0640',
        )
        }

        it { is_expected.to contain_package('foobar') }
      end
    end
  end
end
