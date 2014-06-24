#
# Cookbook Name:: mysql
# Recipe:: ruby
#
# Author:: Jesse Howarth (<him@jessehowarth.com>)
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
# Copyright 2008-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# build-essential-v2.0.0+:
node.set['build-essential']['compile_time'] = true
# build-essential-v1.4.4:
#node.set['build-essential']['compiletime'] = true

include_recipe 'build-essential::default'
include_recipe 'mysql::client'

loaded_recipes = if run_context.respond_to?(:loaded_recipes)
                   run_context.loaded_recipes
                 else
                   node.run_state[:seen_recipes]
                 end

if loaded_recipes.include?('mysql::percona_repo')
  case node['platform_family']
  when 'debian'
    resources('apt_repository[percona]').run_action(:add)
  when 'rhel'
    resources('yum_key[RPM-GPG-KEY-percona]').run_action(:add)
    resources('yum_repository[percona]').run_action(:add)
  end
end

if loaded_recipes.include?('mysql::_mariadb_repo') || node['mysql']['implementation'] == 'mariadb' || node['mysql']['implementation'] == 'galera'
  if !( loaded_recipes.include?('mysql::_mariadb_repo') )
    include_recipe 'mysql::_mariadb_repo'
  end
  case node['platform_family']
  when 'debian'
    resources('apt_repository[mariadb]').run_action(:add)
  end
end

node['mysql']['client']['packages'].each do |name|
  resources("package[#{name}]").run_action(:install)
end

chef_gem 'mysql'
