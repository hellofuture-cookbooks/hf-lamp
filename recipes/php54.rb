#
# Cookbook Name:: hf-lamp
# Recipe:: php54
#
# Copyright 2013, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#
# Install PHP54

if platform?("ubuntu") and node['platform_version'] == '12.04'
  include_recipe 'apt'
  node.default['hf-lamp']['php']['php.ini'] = 'apache-php-54.ini.erb'

  apt_repository "ondrej-php5-oldstable" do
    uri "http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "E5267A6C"
  end  
else
  raise 'Unsupported platform'
end


