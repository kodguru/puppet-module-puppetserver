require 'spec_helper'
describe 'puppetserver::config' do
  let(:facts) do
    {
      :osfamily      => 'RedHat',
      :test          => nil, # used in hiera
    }
  end

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('puppetserver::config') }
    it { should have_file_line_resource_count(2) }
    it { should have_puppetserver__config__java_arg_resource_count(0) }
    it { should have_puppetserver__config__hocon_resource_count(0) }
    it do
      should contain_file_line('ca.certificate-authority-service').with({
        'line'  => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'path'  => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
      })
    end
    it do
      should contain_file_line('ca.certificate-authority-disabled-service').with({
        'line'  => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'path'  => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
      })
    end
  end

  context 'with bootstrap_cfg set to valid string </other/path/to/ca.cfg>' do
    let(:params) { { :bootstrap_cfg => '/other/path/to/ca.cfg' } }

    it { should have_file_line_resource_count(2) }
    it { should contain_file_line('ca.certificate-authority-service').with_path('/other/path/to/ca.cfg') }
    it { should contain_file_line('ca.certificate-authority-disabled-service').with_path('/other/path/to/ca.cfg') }
  end

  context 'with configdir set to valid string </other/path/to/conf.d> when puppetserver_settings and webserver_settings are set' do
    let(:params) do
      {
        :configdir             => '/other/path/to/conf.d',
        :puppetserver_settings => { 'jruby-puppet.max-active-instances' => { 'value' => '6' } },
        :webserver_settings    => { 'rspec' => { 'value' => '242' } },
      }
    end

    it { should contain_puppetserver__config__hocon('jruby-puppet.max-active-instances').with_path('/other/path/to/conf.d/puppetserver.conf') }
    it { should contain_puppetserver__config__hocon('rspec').with_path('/other/path/to/conf.d/webserver.conf') }
  end

  context 'with enable_ca set to valid bool <false>' do
    let(:params) { { :enable_ca => false } }

    it { should have_file_line_resource_count(2) }
    it do
      should contain_file_line('ca.certificate-authority-service').with({
        'line'  => '#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'path'  => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
      })
    end
    it do
      should contain_file_line('ca.certificate-authority-disabled-service').with({
        'line'  => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'path'  => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
      })
    end
  end

  context 'with java_args set to valid hash' do
    let(:params) { { :java_args => { 'rspec' => { 'value' => 'value' } } } }

    it { should have_puppetserver__config__java_arg_resource_count(1) }
    it do
      should contain_puppetserver__config__java_arg('rspec').with({
        'value'  => 'value',
        'notify' => 'Service[puppetserver]',
      })
    end
  end

  context 'with bootstrap_settings set to valid hash' do
    let(:params) { { :bootstrap_settings => { 'rspec' => { 'line' => 'testing242', 'match' => 'testing' } } } }

    it { should have_file_line_resource_count(3) }
    it do
      should contain_file_line('rspec').with({
        'line'  => 'testing242',
        'match' => 'testing',
        'path'  => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
      })
    end
  end

  context 'with puppetserver_settings set to valid hash' do
    let(:params) { { :puppetserver_settings => { 'jruby-puppet.max-active-instances' => { 'value' => '6' } } } }

    it { should have_puppetserver__config__hocon_resource_count(1) }
    it do
      should contain_puppetserver__config__hocon('jruby-puppet.max-active-instances').with({
        'ensure' => 'present',
        'path'   => '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf',
        'value'  => '6',
      })
    end
  end

  context 'with webserver_settings set to valid hash' do
    let(:params) { { :webserver_settings => { 'rspec' => { 'value' => '242' } } } }

    it { should have_puppetserver__config__hocon_resource_count(1) }
    it do
      should contain_puppetserver__config__hocon('rspec').with({
        'ensure' => 'present',
        'path'   => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
        'value'  => '242',
      })
    end
  end

  describe 'with hiera providing data from multiple levels' do
    let(:facts) do
      {
        :fqdn          => 'all_settings',
        :test          => 'all_settings',
      }
    end

    context 'with defaults for all parameters' do
      it { should have_file_line_resource_count(3) }
      it { should contain_file_line('ca.certificate-authority-service') }
      it { should contain_file_line('ca.certificate-authority-disabled-service') }
      it { should contain_file_line('bootstrap_settings_from_hiera_fqdn') }

      it { should have_puppetserver__config__hocon_resource_count(2) }
      it { should contain_puppetserver__config__hocon('puppetserver_settings_from_hiera_fqdn') }
      it { should contain_puppetserver__config__hocon('webserver_settings_from_hiera_fqdn') }
    end

    context 'with bootstrap_settings_hiera_merge set to valid <true>' do
      let(:params) { { :bootstrap_settings_hiera_merge => true } }
      it { should have_file_line_resource_count(4) }
      it { should contain_file_line('ca.certificate-authority-service') }
      it { should contain_file_line('ca.certificate-authority-disabled-service') }
      it { should contain_file_line('bootstrap_settings_from_hiera_fqdn') }
      it { should contain_file_line('bootstrap_settings_from_hiera_test') }
    end

    context 'with puppetserver_settings_hiera_merge set to valid <true>' do
      let(:params) { { :puppetserver_settings_hiera_merge => true } }

      it { should have_puppetserver__config__hocon_resource_count(3) }
      it { should contain_puppetserver__config__hocon('puppetserver_settings_from_hiera_fqdn') }
      it { should contain_puppetserver__config__hocon('puppetserver_settings_from_hiera_test') }
    end

    context 'with webserver_settings_hiera_merge set to valid <true>' do
      let(:params) { { :webserver_settings_hiera_merge => true } }

      it { should have_puppetserver__config__hocon_resource_count(3) }
      it { should contain_puppetserver__config__hocon('webserver_settings_from_hiera_fqdn') }
      it { should contain_puppetserver__config__hocon('webserver_settings_from_hiera_test') }
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        :osfamily      => 'RedHat',
        :test          => nil, # used in hiera
      }
    end
    let(:mandatory_params) { {} }

    validations = {
      'absolute_path' => {
        :name    => %w(bootstrap_cfg configdir),
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'boolean/stringified' => {
        :name    => %w(enable_ca bootstrap_settings_hiera_merge puppetserver_settings_hiera_merge webserver_settings_hiera_merge),
        :valid   => [true, 'true', false, 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(Unknown type of boolean given|is not a boolean)',
      },
      'hash' => {
        :name    => %w(bootstrap_settings java_args puppetserver_settings webserver_settings),
        :valid   => [], # valid hashes are to complex to block test them here.
        :invalid => ['string', 3, 2.42, %w(array), true, nil], # false can't be tested due to implementation
        :message => 'is not a Hash',
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
