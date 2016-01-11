#
# Cookbook Name:: hf-lamp
# Recipe:: default
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'hf-lamp::mysql_server'
include_recipe 'hf-lamp::web'
include_recipe 'hf-lamp::composer'
