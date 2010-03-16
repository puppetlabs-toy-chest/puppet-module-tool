role :web, "staging.modules.puppetlabs.com"
role :app, "staging.modules.puppetlabs.com"
role :db,  "staging.modules.puppetlabs.com", :primary => true

set :rails_env, "staging"
