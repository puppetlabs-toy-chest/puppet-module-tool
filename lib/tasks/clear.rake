namespace :clear do
  task :default => [:cache, :javascripts, :stylesheets]

  task :cache => :environment do
    CacheObserver.expire
  end

  task :javascripts do
    File.join(RAILS_ROOT, 'public', 'javascripts', 'all.js').tap do |file|
      rm file if File.exist? file
    end
  end

  task :stylesheets do
    Dir[File.join(RAILS_ROOT, 'public', 'stylesheets', '*.css')].each do |file|
      rm file
    end
  end
end

desc 'Clear all caches'
task :clear => 'clear:default'
