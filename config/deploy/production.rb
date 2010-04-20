role :web, "modules.puppetlabs.com"
role :app, "modules.puppetlabs.com"
role :db,  "modules.puppetlabs.com", :primary => true

set :user,        "deploy"
set :deploy_to,   "/var/www/apps/#{application}"

set :application, "modulesite"
set :repository,  "git@github.com:bruce/puppet-modulesite.git"
set :scm, :git
