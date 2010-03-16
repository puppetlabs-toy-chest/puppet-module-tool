set :application, "modulesite"
set :repository,  "git@github.com:bruce/puppet-modulesite.git"

set :user,        "deploy"
set :deploy_to,   "/var/www/apps/#{application}"
set :use_sudo, false

set :scm, :git

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "Make symlink for database yaml"
after 'deploy:symlink', :symlink_database_yml

task :symlink_database_yml do
  run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml" 
end
