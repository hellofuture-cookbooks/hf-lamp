#
# Cookbook Name:: hf-lamp
# Recipe:: web
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "hf-lamp::web_dependencies"

apache_site "default" do
  enable false
end

sites = []

if Chef::Config[:solo]
  sites = node['hf-lamp']['sites']
else 
  dsites = data_bag('sites')

  dsites.each do |site|
    item = data_bag_item("sites", site)
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
  else 
    docroot = path + '/' + node['hf-lamp']['web-dir']
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
    template docroot + '/wp-config.php' do
      source 'wp-config.php.erb'
      mode 0755
      owner 'root'
      group 'root'
      variables(
        :database => item['db']['name'],
        :user     => item['db']['user'],
        :password => item['db']['password'],
        :host     => db_host)
    end
  end

  if item.has_key?('passwd_protected')
    passwd = true
  else 
    passwd = false
  end

  web_app item['host'] do
    template "site.conf.erb"
    server_name item['host']
    path path
    docroot docroot
    server_aliases aliases
    url_redirects redirects
    passwd passwd
  end
end