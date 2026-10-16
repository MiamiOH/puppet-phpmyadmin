require 'spec_helper'

describe 'phpmyadmin::debconf', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:title) { 'barfoo' }

      let :params do
        {
          debconf_package: 'foobar'
        }
      end

      context 'compile' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('phpmyadmin::params') }

        it { is_expected.to contain_package('foobar') }

        it {
          is_expected.to contain_exec('barfoo').with(
          'require' => 'Package[foobar]',
        )
        }
      end
    end
  end
end
