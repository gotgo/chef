#
#	util/attributes/default.rb
#


#
# scm
#

include_attribute 'go-chef::logrotate'


default_shell = '/bin/bash'
#deploy_user = 'deploy'
deploy_keep_releases = 5

# The deploy provider used. Set to one of
# - "Branch"      - enables deploy_branch (Chef::Provider::Deploy::Branch)
# - "Revision"    - enables deploy_revision (Chef::Provider::Deploy::Revision)
# - "Timestamped" - enables deploy (default, Chef::Provider::Deploy::Timestamped)
# Deploy provider can also be set at application level.
default_chef_provider = 'Timestamped'
#keep_releases = true
valid_deploy_chef_providers = ['Timestamped', 'Revision', 'Branch']

default[:deploy] = {}

# set defaults
#
node[:deploy].each do |application, deploy|
  default[:deploy][application][:deploy_to] = "/opt/#{application}"
  default[:deploy][application][:chef_provider] = node[:deploy][application][:chef_provider] ? node[:deploy][application][:chef_provider] : default_chef_provider

  unless valid_deploy_chef_providers.include?(node[:deploy][application][:chef_provider])
    raise "Invalid chef_provider '#{node[:deploy][application][:chef_provider]}' for app '#{application}'. Valid providers: #{valid_deploy_chef_providers.join(', ')}."
  end

  default[:deploy][application][:scm][:ssh_key] = ''
  default[:deploy][application][:scm][:revision] = ''
  default[:deploy][application][:scm][:scm_type] = 'git'
  default[:deploy][application][:scm][:repository] = ''

  default[:deploy][application][:keep_releases] = node[:deploy][application][:keep_releases] ? node[:deploy][application][:keep_releases] : deploy_keep_releases
  default[:deploy][application][:current_path] = "#{node[:deploy][application][:deploy_to]}/current"
  default[:deploy][application][:migrate] = false
  default[:deploy][application][:action] = 'deploy'
  default[:deploy][application][:user] = application
  default[:deploy][application][:group] = application
  default[:deploy][application][:shell] = default_shell
  default[:deploy][application][:home] = "/home/#{self[:deploy][application][:user]}"
  default[:deploy][application][:sleep_before_restart] = 0
  default[:deploy][application][:enable_submodules] = true
  default[:deploy][application][:shallow_clone] = false
  default[:deploy][application][:delete_cached_copy] = true
  default[:deploy][application][:create_dirs_before_symlink] = ['tmp', 'public', 'config']
  default[:deploy][application][:symlink_before_migrate] = {}
  default[:deploy][application][:environment] = { "HOME" => node[:deploy][application][:home]}

end

#include_attribute "deploy::customize"

