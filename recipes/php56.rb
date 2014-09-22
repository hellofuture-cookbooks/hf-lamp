#
# Cookbook Name:: hf-lamp
# Recipe:: php56
#
# Copyright 2014, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#
# Install PHP54

if platform?("ubuntu") and node.platform_version == '14.04'
  include_recipe 'apt'
  node.default['hf-lamp']['php']['php.ini'] = 'apache-php-56.ini.erb'

  apt_repository "ondrej-php5-56" do
    uri "http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "E5267A6C"
  end  
else
  raise 'Unsupported platform'
end


