require 'spec_helper'
describe 'puppetserver::config::java_arg' do
  mandatory_global_facts = {
    osfamily: 'RedHat', # used in puppetserver::config::java_arg define
    test:     nil,      # used in hiera
  }

  mandatory_params = {
    value: 'value',
  }

  let(:title) { 'rspec_title' }
  let(:facts) { mandatory_global_facts }
  let(:params) { mandatory_params }

  describe 'with defaults for all parameters' do
    let(:params) { {} } # unset params to allow failing

    it 'fails' do
      expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{(expects a value for|Must pass value to)})
    end
  end

  describe 'with mandatory parameters set to valid values' do
    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_ini_subsetting('java_arg-rspec_title').with(
        'ensure'     => 'present',
        'path'       => '/etc/sysconfig/puppetserver',
        'section'    => '',
        'setting'    => 'JAVA_ARGS',
        'quote_char' => '"',
        'subsetting' => 'rspec_title',
        'value'      => 'value',
      )
    end
  end

  describe 'with mandatory parameters set to valid values on Debian' do
    let(:facts) { mandatory_global_facts.merge({ osfamily: 'Debian' }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_ini_subsetting('java_arg-rspec_title').with_path('/etc/default/puppetserver') }
  end

  describe 'with value set to valid string \'test\'' do
    let(:params) { mandatory_params.merge({ value: 'test' }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_ini_subsetting('java_arg-rspec_title').with_value('test') }
  end

  ['absent', 'present'].each do |value|
    describe "with ensure set to valid string \'#{value}\'" do
      let(:params) { mandatory_params.merge({ ensure: value }) }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_ini_subsetting('java_arg-rspec_title').with_ensure(value) }
    end
  end
end
