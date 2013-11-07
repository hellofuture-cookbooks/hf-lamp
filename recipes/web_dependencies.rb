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