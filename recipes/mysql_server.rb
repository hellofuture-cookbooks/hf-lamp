#
# Cookbook Name:: phpapp
# Recipe:: mysql_server
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "hf-lamp::mysql_dependencies"

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

  if item.has_key?('db') and item.has_key?('manage_db')
    mysql_database item['db']['name'] do
      connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
      action :create
    end

    mysql_database_user item['db']['user'] do
      connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
      password item['db']['password']
      database_name item['db']['name']
      host item['db']['host']
      privileges [:select,:update,:alter,:insert,:create,:delete,:drop]
      action :grant
    end
  end
end