#
# Cookbook Name:: hf-lamp
# Recipe:: web
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "hf-lamp::web_dependencies"

if platform?("ubuntu")
  template '/etc/php5/apache2/php.ini' do 
    source node.default['hf-lamp']['php']['php.ini']
    notifies :restart, "service[apache2]"
  end
end

directory File.join(node['apache']['dir'], 'conf.d') do 
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  action :create
end

template File.join(node['apache']['dir'], 'conf.d', 'combined_new.conf') do
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :restart, 'service[apache2]'
end

apache_site "default" do
  enable false
end

sites = []

if Chef::Config[:solo]
  sites = node['hf-lamp']['sites']
else 
  dsites = data_bag(node['hf-lamp']['sites-databag'])

  dsites.each do |site|
    item = data_bag_item(node['hf-lamp']['sites-databag'], site)
    sites.push(item)
  end
end

sites.each do |item|

  # Any virtual host aliases?

  if item.has_key?('aliases')
    aliases = item['aliases'] 
  else
    aliases = []
  end

  # Any redirects?

  if item.has_key?('redirects')
    redirects = item['redirects'] 
  else
    redirects = {}
  end

  if item.has_key?('single-vhost')
    # So we can 
    path = node['hf-lamp']['docroot-dir']
  else 
    if item.has_key?('path')
        path = node['hf-lamp']['docroot-dir'] + '/' + item['path']
    else
        path = node['hf-lamp']['docroot-dir'] + '/' + item['host']
    end
  end
 
  if item.has_key?('docroot')
    docroot = path + '/' + item['docroot']
  elsif node['hf-lamp']['has-web-dir']
    docroot = path + '/' + node['hf-lamp']['web-dir']
  else
    docroot = path
  end

  directory docroot do
    owner 'root'
    group 'root'
    mode 0755
    action :create
    recursive true
  end

  if item.has_key?('db') and item['db'].has_key?('host')
    db_host = item['db']['host']
  else
    db_host = 'localhost'
  end

  if item.has_key?('wordpress') and item.has_key?('db')

    if item['wordpress'].has_key?('prefix')
      prefix = item['wordpress']['prefix']
    else
      prefix = node['hf-lamp']['wordpress']['prefix']
    end

    template docroot + '/wp-config.php' do
      source 'wp-config.php.erb'
      mode 0755
      owner 'root'
      group 'root'
      variables(
        :database => item['db']['name'],
        :user     => item['db']['user'],
        :password => item['db']['password'],
        :prefix   => prefix,
        :host     => db_host)
    end
  end

  # magento support isn't finished
  # if item.has_key?('magento')
  #   if item['magento'].has_key?('install')
  #     magento_path = File.join(Chef::Config['file_cache_path'], 'magento.tar.gz')

  #     remote_file magento_path do
  #       source node['hf-lamp']['magento']['url']
  #       mode "0644"
  #     end

  #     execute 'untar-magento' do
  #       cwd docroot
  #       command 'tar --strip-components 1 -xzf ' + magento_path
  #     end

  #     user = 'www-data'
  #     group = 'www-data'

  #     bash "Ensure correct permissions & ownership" do
  #       cwd docroot
  #       code <<-EOH
  #         chown -R #{user}:#{group} #{docroot}
  #         chmod -R o+w media
  #         chmod -R o+w var
  #       EOH
  #     end
  #   end
  # end

  if item.has_key?('passwd_protected')
    passwd = true
  else 
    passwd = false
  end

  if node['hf-lamp'].has_key?('log_path')
    log_path = node['hf-lamp']['log_path']
  else 
    log_path = path
  end

  if node['hf-lamp'].has_key?('per-host-log') and node['hf-lamp']['per-host-log']
    if item.has_key?('path')
      log_path = File.join(log_path, item['path'])
    else
      log_path = File.join(log_path, item['host'])
    end
  end

  if item.has_key?('extra_directives')
    extra_directives = item['extra_directives']
  else 
    extra_directives = []
  end

  if item.has_key?('canonical_redirect')
    canonical_redirect = true
  else 
    canonical_redirect = false
  end

  directory log_path do
    owner 'root'
    group 'root'
    mode 0755
    action :create
  end

  web_app item['host'] do
    template "site.conf.erb"
    server_name item['host']
    port node['hf-lamp']['port']
    log_path log_path
    log_format node['hf-lamp']['access-log-format'] 
    path path
    docroot docroot
    server_aliases aliases
    url_redirects redirects
    passwd passwd
    extra_directives extra_directives
    canonical_redirect canonical_redirect
  end
end
