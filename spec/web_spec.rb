require 'spec_helper'

describe 'hf-lamp::web' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04')
  end

  apache2_binary = '/usr/sbin/apache2'
  php_ini = '/etc/php5/apache2/php.ini'
  sites_available = '/etc/apache2/sites-available'

  before do
    Fauxhai.mock(platform: 'ubuntu', version: '12.04')
    stub_command(apache2_binary + ' -t').and_return(true)
  end

  it 'should include the web_dependencies recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('hf-lamp::web_dependencies')
  end

  it 'should write out a custom php.ini' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(php_ini)
  end

  it 'should write out a andygale.conf' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => false
    )
  end

  it 'adds specified server aliases' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'aliases' => ['www.andy-gale.com'] }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => ['www.andy-gale.com'],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => false
    )
  end

  it 'adds specified redirects' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'redirects' => { '/redirect' => '/redirect_to' } }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => { '/redirect' => '/redirect_to' },
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => false
    )
  end

  it 'honours single-vhost option' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'single-vhost' => true }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www',
      :log_format => 'combined',
      :path => '/var/www',
      :docroot => '/var/www/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => false
    )
  end

  it 'uses path instead of host for path when specified' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'stage.andy-gale.com', 'path' => 'andy-gale.com' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/stage.andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'stage.andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'stage.andy-gale.com',
      :vagrant => false
    )
  end

  it 'honours docroot option' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'docroot' => 'webroot' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/webroot',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => false
    )
  end

  it 'creates docroot directory' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_directory('/var/www/andy-gale.com/www').with_owner('www-data').with_group('www-data').with_mode(0755).with_action([:create]).with_recursive(true)
  end

  it 'creates docroot directory with custom user if specified' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'user' => 'andygale' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_directory('/var/www/andy-gale.com/www').with_owner('andygale').with_group('www-data').with_mode(0755).with_action([:create]).with_recursive(true)
  end

  it 'creates docroot directory with custom group if specified' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'group' => 'andygale' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_directory('/var/www/andy-gale.com/www').with_owner('www-data').with_group('andygale').with_mode(0755).with_action([:create]).with_recursive(true)
  end

  it 'creates docroot directory with custom user and group if specified' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'user' => 'andygale', 'group' => 'andygale' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_directory('/var/www/andy-gale.com/www').with_owner('andygale').with_group('andygale').with_mode(0755).with_action([:create]).with_recursive(true)
  end

  it 'writes WordPress configuration if db and wordpress options are set' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{
      'id' => 'andygale',
      'host' => 'andy-gale.com',
      'wordpress' => true,
      'db' => {
        'name' => 'a',
        'user' => 'a',
        'password' => 'a'
      }
    }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/var/www/andy-gale.com/www/wp-config.php').with_variables(
      :database => 'a',
      :user => 'a',
      :password => 'a',
      :host => 'localhost',
      :prefix => 'wp_'
    )
  end

  it 'writes correction prefix in WordPress configuration' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{
      'id' => 'andygale',
      'host' => 'andy-gale.com',
      'wordpress' => {
        'prefix' => 'face_'
      },
      'db' => {
        'name' => 'a',
        'user' => 'a',
        'password' => 'a'
      }
    }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/var/www/andy-gale.com/www/wp-config.php').with_variables(
      :database => 'a',
      :user => 'a',
      :password => 'a',
      :host => 'localhost',
      :prefix => 'face_'
    )
  end

  it 'writes correction db host in WordPress configuration' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{
      'id' => 'andygale',
      'host' => 'andy-gale.com',
      'wordpress' => {
        'prefix' => 'face_'
      },
      'db' => {
        'name' => 'a',
        'user' => 'a',
        'password' => 'a',
        'host' => '10.0.66.6'
      }
    }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/var/www/andy-gale.com/www/wp-config.php').with_variables(
      :database => 'a',
      :user => 'a',
      :password => 'a',
      :host => '10.0.66.6',
      :prefix => 'face_'
    )
  end

  it 'honours the passwd_protected option' do
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'passwd_protected' => true }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => true,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => false
    )
  end

  it 'honours the log_path attribute' do
    chef_run.node.automatic['hf-lamp']['log_path'] = '/data/log'
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/data/log',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => false
    )
  end

  it 'honours the vagrant attribute' do
    chef_run.node.automatic['hf-lamp']['vagrant'] = true
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com' }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => [],
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => true
    )
  end

  it 'honours the directory_directives attribute' do
    dir_dir = [
      'RewriteEngine On', 'RewriteBase /', 'RewriteCond %{REQUEST_FILENAME} !-f',
      'RewriteRule ^ index.php [QSA,L]'
    ]
    chef_run.node.automatic['hf-lamp']['vagrant'] = true
    chef_run.node.automatic['hf-lamp']['sites'] = [{ 'id' => 'andygale', 'host' => 'andy-gale.com', 'directory_directives' => dir_dir }]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template(sites_available + '/andy-gale.com.conf').with_params(
      :template => 'site.conf.erb',
      :local => false,
      :enable => true,
      :server_name => 'andy-gale.com',
      :port => 80,
      :server_port => 80,
      :log_path => '/var/www/andy-gale.com',
      :log_format => 'combined',
      :path => '/var/www/andy-gale.com',
      :docroot => '/var/www/andy-gale.com/www',
      :server_aliases => [],
      :url_redirects => {},
      :passwd => false,
      :extra_directives => [],
      :directory_directives => dir_dir,
      :canonical_redirect => false,
      :name => 'andy-gale.com',
      :vagrant => true
    )
  end
end
