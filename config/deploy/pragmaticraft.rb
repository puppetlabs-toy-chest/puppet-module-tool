set :user, "igal"
set :host, "dev.pragmaticraft.com"
role :web, host
role :app, host 
role :db,  host, :primary => true
set :deploy_to, "/var/www/puppet-modules"

set :scm, :git
set :git_shallow_copy, 1
set :repository, '.'
set :deploy_via, :copy
set :copy_cache, true
set :copy_exclude, ['.git', 'log', 'tmp', '*.sql', '*.diff', 'coverage.info', 'coverage', 'public/images/members', 'public/system', 'tags', 'db/remote.sql', 'db/*.sqlite3', '*.swp', '.*.swp']
default_run_options[:pty] = true
