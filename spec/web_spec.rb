require 'spec_helper'

describe 'hf-lamp::web' do
  let(:chef_run) do
    ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com' }]
    end.converge(described_recipe)
  end

  apache2_binary = '/usr/sbin/apache2'
  php_ini = '/etc/php5/apache2/php.ini'
  conf_d = '/etc/apache2/conf.d'
  sites_available = '/etc/apache2/sites-available'

  before do
    Fauxhai.mock(platform: 'ubuntu', version: '12.04')
    stub_command(apache2_binary + ' -t').and_return(true)
  end

  it 'should include the web_dependencies recipe' do
    expect(chef_run).to include_recipe('hf-lamp::web_dependencies')
  end

  it 'should write out a custom php.ini' do
    expect(chef_run).to create_template(php_ini)
  end

  it 'should create the directory conf.d' do
    expect(chef_run).to create_directory(conf_d).with_user('root')
  end

  it 'should write out combined_new.conf' do
    expect(chef_run).to create_template(conf_d + '/combined_new.conf')
  end

  it 'should write out a andygale.conf' do
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com'
    )
  end

end
