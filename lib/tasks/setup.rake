namespace :setup do
  desc %{Create or update the "admin" user and their password. Specify PASSWORD environmental variable to avoid prompt.}
  task :admin => :environment do
    email = SECRETS.administrator_email
    password = 
      begin
        ENV["PASSWORD"] ||
        begin
          print %{?? Enter the password to use for the website's "admin" user: }
          STDOUT.flush
          STDIN.readline
        end
      end.strip

    if user = User.find_by_username("admin")
      user.password = user.password_confirmation = password
      user.admin = true
      user.save!
      puts %{** Updated "admin" user's password}
    else
      user = User.new(
        :username => "admin",
        :email => email,
        :display_name => "Admin",
        :password => password,
        :password_confirmation => password)
      user.admin = true
      # TODO why do I have to confirm the user twice for it to work?
      user.confirm!
      user.confirm!
      user.save!
      puts %{** Created new "admin" user}
    end
  end

  namespace :admin do
    desc "Grant admin rights. Specify space/comma-separated USERNAMES environmental variable to avoid prompt."
    task :grants => :environment do
      usernames = 
        begin
          ENV["USERNAMES"] ||
          begin
            print "?? Enter space and/or comma separated usernames to give admin rights to: "
            STDOUT.flush
            STDIN.readline
          end
        end.strip

      for username in usernames.split(/[\s+|,]+/)
        if user = User.find_by_username(username)
          user.update_attribute(:admin, true)
          puts " - Granted rights to #{username.inspect}"
        else
          puts " ! Can't find user #{username.inspect}"
        end
      end
    end
  end
end

desc "Setup application's directories, configurations and admin user"
task :setup do
  # Create transient directories
  [
    File.join(RAILS_ROOT, "log"),
    File.join(RAILS_ROOT, "tmp"),
  ].each do |directory|
    mkdir_p directory unless File.exist?(directory)
  end

  # Copy sample configuration files into place
  [
    "config/database~sample.yml",
    "spec/spec~sample.opts",
    "spec/rcov~sample.opts",
  ].each do |filename|
    source = File.join(RAILS_ROOT, filename)
    target = File.join(RAILS_ROOT, filename.sub(/~sample/, ""))
    cp(source, target) unless File.exist?(target)
  end

  Rake::Task['setup:admin'].invoke
end
