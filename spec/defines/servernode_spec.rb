require 'spec_helper'

describe 'phpmyadmin::servernode', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:title) { 'barfoo' }

      let :params do
        {
          server_group: 'foobar',
          myserver_name: 'foobar.my.com',
          verbose_name: 'foobar.verbose',
          target: '/foobar'
        }
      end

      context 'compile' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('phpmyadmin::params') }

        it {
          is_expected.to contain_concat__fragment(
          'foobar_phpmyadmin_server_barfoo',
        ).with(
          'target' => '/foobar',
          'order'  => '20-foobar-foobar.my.com',
        )
        }
      end
    end
  end
end
