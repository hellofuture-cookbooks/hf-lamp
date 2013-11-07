#
# Cookbook Name:: hf-lamp
# Recipe:: htpasswds

cookbook_file "/etc/apache2/passwds" do
  source "passwds"
  mode "0755"
end