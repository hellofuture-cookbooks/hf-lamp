#
# Cookbook Name:: hf-lamp
# Recipe:: web
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

node.set['apache']['mpm'] = 'prefork'

include_recipe 'hf-lamp::web_dependencies'

template '/etc/php5/apache2/php.ini' do
  source node.default['hf-lamp']['php']['php.ini']
  notifies :restart, 'service[apache2]'
  only_if { node['platform'] == 'ubuntu' }
end

apache_conf 'combined_new' do
  enable true
end

sites = []

if Chef::Config[:solo]
  sites = node['hf-lamp']['sites'] if node['hf-lamp'].key?('sites')
else
  dsites = data_bag(node['hf-lamp']['sites-databag'])

  dsites.each do |site|
    item = data_bag_item(node['hf-lamp']['sites-databag'], site)
    sites.push(item)
  end
end

composer_done = false

sites.each do |item|
  # Any virtual host aliases?

  if item.key?('aliases')
    aliases = item['aliases']
  else
    aliases = []
  end

  # Any redirects?

  if item.key?('redirects')
    redirects = item['redirects']
  else
    redirects = {}
  end

  if item.key?('single-vhost')
    path = node['hf-lamp']['docroot-dir']
  else
    if item.key?('path')
      path = node['hf-lamp']['docroot-dir'] + '/' + item['path']
    else
      path = node['hf-lamp']['docroot-dir'] + '/' + item['host']
    end
  end

  if item.key?('docroot')
    docroot = path + '/' + item['docroot']
  elsif node['hf-lamp']['has-web-dir']
    docroot = path + '/' + node['hf-lamp']['web-dir']
  else
    docroot = path
  end

  # Use default apache users not root

  if item.key?('user')
    user = item['user']
  else
    user = node['apache']['user']
  end

  if item.key?('group')
    group = item['group']
  else
    group = node['apache']['group']
  end

  directory docroot do
    owner user
    group group
    mode 0755
    action :create
    recursive true
  end

  if item.key?('wordpress') && item.key?('db')

    if item.key?('db') && item['db'].key?('host')
      db_host = item['db']['host']
    else
      db_host = 'localhost'
    end

    if item['wordpress'].is_a?(Hash) && item['wordpress'].key?('prefix')
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
        :host     => db_host,
        :prefix   => prefix)
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

  if item.key?('passwd_protected')
    passwd = true
  else
    passwd = false
  end

  if node['hf-lamp'].key?('log_path')
    log_path = node['hf-lamp']['log_path']

    directory log_path do
      owner 'root'
      group 'root'
      mode 0755
      action :create
    end
  else
    log_path = path
  end

  if node['hf-lamp'].key?('per-host-log') && node['hf-lamp']['per-host-log']
    if item.key?('path')
      log_path = File.join(log_path, item['path'])
    else
      log_path = File.join(log_path, item['host'])
    end
  end

  if item.key?('extra_directives')
    extra_directives = item['extra_directives']
  else
    extra_directives = []
  end

  if item.key?('canonical_redirect')
    canonical_redirect = true
  else
    canonical_redirect = false
  end

  web_app item['host'] do
    template 'site.conf.erb'
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

  if item.key?('composer')
    unless composer_done
      include_recipe 'composer'
      composer_done = true
    end

    if item['composer'].key?('dev') && item['composer']['dev']
      dev = false
    else
      dev = true 
    end

    if item['composer'].key('path')
      composer_path = item['composer']['path']
    else
      composer_path = path
    end

    if item['composer'].key('action')
      composer_action = item['composer']['action']
    else
      composer_action = :install
    end

    composer_project composer_path do
      dev dev
      quiet true
      action composer_action
      only_if { ::File.exist?(File.join(composer_path, 'composer.json')) }
    end
  end
end
