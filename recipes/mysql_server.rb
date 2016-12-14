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

  # Support both db and new dbs (i.e. more than one)

  next unless item.key?('manage_db')

  dbs = []

  if item.key?('dbs')
    item['dbs'].each do |db|
      dbs.push(
        name: db['name'],
        user: db['user'],
        password: db['password'],
        host: db['host']
      )
    end
  end

  dbs.push(
    name: item['db']['name'],
    user: item['db']['user'],
    password: item['db']['password'],
    host: item['db']['host']
  ) if item.key?('db')

  dbs.each do |db|
    log db
    mysql_database db[:name] do
      connection db_connection
      action :create
    end

    mysql_database_user db[:user] do
      connection db_connection
      password db[:password]
      database_name db[:name]
      host db[:host]
      privileges [:select, :update, :alter, :insert, :create, :delete]
      action :grant
    end
  end
end
