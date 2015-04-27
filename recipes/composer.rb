#
# Cookbook Name:: hf-lamp
# Recipe:: composer
#
# Copyright 2015, Hello Future Ltd
#
# All rights reserved - Do Not Redistribute
#

composer_done = false

node['hf-lamp']['use_sites'].each do |item|
  # Only include the composer recipe if we need to

  next unless item.key?('composer')
  unless composer_done
    include_recipe 'composer'
    composer_done = true
  end

  if item['composer'].key?('dev') && item['composer']['dev']
    dev = false
  else
    dev = true
  end

  if item['composer'].key('path')
    composer_path = item['composer']['path']
  else
    composer_path = path
  end

  if item['composer'].key('action')
    composer_action = item['composer']['action']
  else
    composer_action = :install
  end

  composer_project composer_path do
    dev dev
    quiet true
    action composer_action
    only_if { ::File.exist?(File.join(composer_path, 'composer.json')) }
  end
end
