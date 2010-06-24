namespace :db do 
  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n' 
  task :rollback => :environment do 
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1 
    version = ActiveRecord::Migrator.current_version - step 
    ActiveRecord::Migrator.migrate('db/migrate/', version) 
  end 
end
