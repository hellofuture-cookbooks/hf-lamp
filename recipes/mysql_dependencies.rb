#
# Cookbook Name:: hf-lamp
# Recipe:: mysql_dependencies
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

chef_gem 'mysql2'

include_recipe 'mysql::server'
include_recipe 'mysql::ruby'
