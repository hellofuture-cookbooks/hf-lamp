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

  hf = HfLamp.item(node, item)

  composer_project hf[:composer_path] do
    dev hf[:composer_dev]
    quiet true
    action hf[:composer_action]
    only_if { ::File.exist?(File.join(hf[:composer_path], 'composer.json')) }
  end
end
