require 'spec_helper'
describe 'puppetserver::config::java_arg' do
  let(:title) { 'rspec_title' }
  let(:facts) { { :osfamily => 'RedHat' } }
  let(:mandatory_params) { { :value => 'value' } }

  describe 'with defaults for all parameters' do
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for|Must pass value to)/)
    end
  end

  describe 'with mandatory parameters set to valid values' do
    let(:params) { mandatory_params }
    it { should compile.with_all_deps }

    it do
      should contain_ini_subsetting('java_arg-rspec_title').with({
        'ensure'     => 'present',
        'path'       => '/etc/sysconfig/puppetserver',
        'section'    => '',
        'setting'    => 'JAVA_ARGS',
        'quote_char' => '"',
        'subsetting' => 'rspec_title',
        'value'      => 'value',
      })
    end
  end

  describe 'with mandatory parameters set to valid values on Debian' do
    let(:facts) { { :osfamily => 'Debian' } }
    let(:params) { mandatory_params }
    it { should compile.with_all_deps }

    it { should contain_ini_subsetting('java_arg-rspec_title').with_path('/etc/default/puppetserver') }
  end

  describe 'with value set to valid string \'test\'' do
    let(:params)  { { :value => 'test' } }
    it { should compile.with_all_deps }

    it { should contain_ini_subsetting('java_arg-rspec_title').with_value('test') }
  end

  %w(absent present).each do |value|
    describe "with ensure set to valid string \'#{value}\'" do
      let(:params) { mandatory_params.merge({ :ensure => value }) }
      it { should compile.with_all_deps }

      it { should contain_ini_subsetting('java_arg-rspec_title').with_ensure(value) }
    end
  end
end
