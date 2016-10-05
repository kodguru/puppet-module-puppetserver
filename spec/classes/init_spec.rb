require 'spec_helper'
describe 'puppetserver' do
  let(:facts) do
    {
      :test          => nil, # used in hiera
    }
  end

  describe 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('puppetserver') }
    it { should contain_class('puppetserver::config').with_notify(['Service[puppetserver]']) }

    it do
      should contain_package('puppetserver').with({
        'ensure' => 'installed',
        'before' => ['Service[puppetserver]', 'Class[Puppetserver::Config]'],
      })
    end

    it do
      should contain_service('puppetserver').with({
        'ensure'  => 'running',
        'enable'  => true,
      })
    end
  end

  %w(installed present absent 2.4.2).each do |value|
    describe "with package_ensure set to valid string '#{value}'" do
      let(:params) { { :package_ensure => value } }
      it { should contain_package('puppetserver').with_ensure(value) }
    end
  end

  describe 'with package_name set to valid string \'puppetserver_new\'' do
    let(:params) { { :package_name => 'puppetserver_new' } }
    it { should compile.with_all_deps }
    it { should contain_package('puppetserver_new') }
  end

  describe 'with package_name set to valid array [\'pkg1\',\'pkg2\']' do
    let(:params) { { :package_name => %w(pkg1 pkg2) } }
    it { should compile.with_all_deps }
    it { should contain_package('pkg1') }
    it { should contain_package('pkg2') }
  end

  describe 'with service_enable set to valid bool <false>' do
    let(:params) { { :service_enable => false } }
    it { should compile.with_all_deps }
    it { should contain_service('puppetserver').with_enable(false) }
  end

  %w(running stopped).each do |value|
    describe "with service_ensure set to valid string '#{value}'" do
      let(:params) { { :service_ensure => value } }
      it { should contain_service('puppetserver').with_ensure(value) }
    end
  end

  describe 'with service_name set to valid string \'puppetsrv\'' do
    let(:params) { { :service_name => 'puppetsrv' } }
    it { should compile.with_all_deps }
    it { should contain_service('puppetsrv') }
    it { should contain_class('puppetserver::config').with_notify(['Service[puppetsrv]']) }
    it { should contain_package('puppetserver').with_before(['Service[puppetsrv]', 'Class[Puppetserver::Config]']) }
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        :test          => nil, # used in hiera
      }
    end
    let(:mandatory_params) { {} }

    validations = {
      'array/string' => {
        :name    => %w(package_name),
        :valid   => ['string', %w(array)],
        :invalid => [{ 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not an array nor a string',
      },
      'boolean/stringified' => {
        :name    => %w(service_enable),
        :valid   => [true, 'true', false, 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given)',
      },
      'regex package_ensure' => {
        :name    => %w(package_ensure),
        :valid   => %w(installed present absent 2.4.2),
        :invalid => ['string', '2.4.2.0', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'puppetserver::package_ensure must be one of <installed>, <present>, <absent>, or a semantic version number',
      },
      'regex service_ensure' => {
        :name    => %w(service_ensure),
        :valid   => %w(running stopped),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'service_ensure must be one of <running> or <stopped>',
      },
      'string' => {
        :name    => %w(service_name),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
