#
# Cookbook Name:: hf-lamp
# Recipe:: composer
#
# Copyright 2014, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'composer'


composer_project node['hf-lamp']['docroot-dir'] do
  dev node['hf-lamp']['composer_dev']
  quiet false
  action node['hf-lamp']['composer_action']
end