require 'spec_helper'
describe 'puppetserver' do
  mandatory_params = {}
  mandatory_global_facts = {
    osfamily: 'RedHat', # used in puppetserver::config::java_arg define
    test:     nil,      # used in hiera
  }

  let(:facts) { mandatory_global_facts }
  let(:params) { mandatory_params }

  describe 'with defaults for all parameters' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('puppetserver') }
    it { is_expected.to contain_class('puppetserver::config').with_notify(['Service[puppetserver]']) }

    it do
      is_expected.to contain_package('puppetserver').with(
        'ensure' => 'installed',
        'before' => ['Service[puppetserver]', 'Class[Puppetserver::Config]'],
      )
    end

    it do
      is_expected.to contain_service('puppetserver').with(
        'ensure'  => 'running',
        'enable'  => true,
      )
    end
  end

  ['installed', 'present', 'absent', '2.4.2'].each do |value|
    describe "with package_ensure set to valid string '#{value}'" do
      let(:params) { mandatory_params.merge({ package_ensure: value }) }

      it { is_expected.to contain_package('puppetserver').with_ensure(value) }
    end
  end

  describe 'with package_name set to valid string \'puppetserver_new\'' do
    let(:params) { mandatory_params.merge({ package_name: 'puppetserver_new' }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('puppetserver_new') }
  end

  describe 'with package_name set to valid array [\'pkg1\',\'pkg2\']' do
    let(:params) { mandatory_params.merge({ package_name: ['pkg1', 'pkg2'] }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('pkg1') }
    it { is_expected.to contain_package('pkg2') }
  end

  describe 'with service_enable set to valid bool <false>' do
    let(:params) { mandatory_params.merge({ service_enable: false }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_service('puppetserver').with_enable(false) }
  end

  ['running', 'stopped'].each do |value|
    describe "with service_ensure set to valid string '#{value}'" do
      let(:params) { mandatory_params.merge({ service_ensure: value }) }

      it { is_expected.to contain_service('puppetserver').with_ensure(value) }
    end
  end

  describe 'with service_name set to valid string \'puppetsrv\'' do
    let(:params) { mandatory_params.merge({ service_name: 'puppetsrv' }) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_service('puppetsrv') }
    it { is_expected.to contain_class('puppetserver::config').with_notify(['Service[puppetsrv]']) }
    it { is_expected.to contain_package('puppetserver').with_before(['Service[puppetsrv]', 'Class[Puppetserver::Config]']) }
  end

  describe 'variable type and content validations' do
    validations = {
      'array/string' => {
        name:    ['package_name'],
        valid:   ['string', ['array']],
        invalid: [{ 'ha' => 'sh' }, 3, 2.42, true, false],
        message: 'is not an array nor a string',
      },
      'boolean/stringified' => {
        name:    ['service_enable'],
        valid:   [true, 'true', false, 'false'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
        message: '(is not a boolean|Unknown type of boolean given)',
      },
      'regex package_ensure' => {
        name:    ['package_ensure'],
        valid:   ['installed', 'present', 'absent', '2.4.2'],
        invalid: ['string', '2.4.2.0', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        message: 'puppetserver::package_ensure must be one of <installed>, <present>, <absent>, or a semantic version number',
      },
      'regex service_ensure' => {
        name:    ['service_ensure'],
        valid:   ['running', 'stopped'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        message: 'service_ensure must be one of <running> or <stopped>',
      },
      'string' => {
        name:    ['service_name'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, true, false],
        message: 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": valid, }].reduce(:merge) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

            it 'fails' do
              expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
