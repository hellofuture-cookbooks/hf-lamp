#
# Cookbook Name:: hf-lamp
# Recipe:: web_dependencies
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"
include_recipe "mysql::client"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"

if node['hf-lamp']['php-modules'] and node['hf-lamp']['php-modules'].count > 0
  modules = node['hf-lamp']['php-modules']
else
  modules = nil
end

if modules
  modules.each do |p|
    package node['hf-lamp']['php-module-prefix'] + '-' + p do
      action :install
    end
  end
end
