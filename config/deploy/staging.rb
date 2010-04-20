role :web, "staging.modules.puppetlabs.com"
role :app, "staging.modules.puppetlabs.com"
role :db,  "staging.modules.puppetlabs.com", :primary => true

set :user,        "deploy"
set :deploy_to,   "/var/www/apps/#{application}"

set :application, "modulesite"
set :repository,  "git@github.com:bruce/puppet-modulesite.git"
set :scm, :git

# set :rails_env, "staging"
