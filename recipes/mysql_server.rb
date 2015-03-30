#
# Cookbook Name:: hf-lamp
# Recipe:: mysql_server
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'hf-lamp::mysql_dependencies'

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
  db_connection = { :host => 'localhost',
                    :username => 'root',
                    :password => node['mysql']['server_root_password'] }

  next if !item.key?('db') && !item.key?('manage_db')

  mysql_database item['db']['name'] do
    connection db_connection
    action :create
  end

  mysql_database_user item['db']['user'] do
    connection db_connection
    password item['db']['password']
    database_name item['db']['name']
    host item['db']['host']
    privileges [:select, :update, :alter, :insert, :create, :delete]
    action :grant
  end
end
