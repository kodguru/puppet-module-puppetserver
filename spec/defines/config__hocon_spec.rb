require 'spec_helper'
describe 'puppetserver::config::hocon' do
  mandatory_global_facts = {
    osfamily: 'RedHat', # used in puppetserver::config::java_arg define
    test:     nil,      # used in hiera
  }

  mandatory_params = {
    value: 'value',
    path: '/rspec',
  }

  let(:title) { 'rspec_title' }
  let(:facts) { mandatory_global_facts }
  let(:params) { mandatory_params }

  describe 'with defaults for all parameters' do
    let(:params) { {} } # unset params to allow failing

    it 'fails' do
      expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{(expects a value for|Must pass)})
    end
  end

  describe 'with mandatory parameters set to valid values' do
    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_hocon_setting('hocon-rspec_title').with(
        'ensure'  => 'present',
        'path'    => '/rspec',
        'setting' => 'rspec_title',
        'value'   => 'value',
        'type'    => nil,
      )
    end
  end

  describe 'with value set to valid string \'test\'' do
    let(:params) { mandatory_params.merge({ value: 'test' }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_hocon_setting('hocon-rspec_title').with_value('test') }
  end

  describe 'with path set to valid string \'/rspec/test\'' do
    let(:params) { mandatory_params.merge({ path: '/rspec/test' }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_hocon_setting('hocon-rspec_title').with_path('/rspec/test') }
  end

  describe 'with setting set to valid string \'test\'' do
    let(:params) { mandatory_params.merge({ setting: 'test' }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_hocon_setting('hocon-rspec_title').with_setting('test') }
  end

  ['absent', 'present'].each do |value|
    describe "with ensure set to valid string \'#{value}\'" do
      let(:params) { mandatory_params.merge({ ensure: value }) }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_hocon_setting('hocon-rspec_title').with_ensure(value) }
    end
  end

  types = {
    'boolean' => [true, false],
    'string'  => ['string'],
    'text'    => ['text'],
    'number'  => ['2.42', 2.42, '3', 3],
    'array'   => [['array']],
    'hash'    => [{ 'ha' => 'sh' }],
  }

  types.each do |type, values|
    values.each do |value|
      describe "with type set to valid '#{type}' and value set to #{value} (as #{value.class})" do
        let(:params) { mandatory_params.merge({ type: type, value: value }) }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_hocon_setting('hocon-rspec_title').with_type(type) }
      end
    end
  end
end
