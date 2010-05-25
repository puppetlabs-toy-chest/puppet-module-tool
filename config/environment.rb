# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '~> 2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  # Gems
  config.gem 'acts-as-taggable-on', :version => '2.0.4'
  config.gem 'archive-tar-minitar', :lib => 'archive/tar/minitar'
  config.gem 'bcrypt-ruby', :lib => 'bcrypt'
  config.gem 'bitmask-attribute', :version => '>= 1.1.0'
  config.gem 'devise', :version => '~> 1.0.7'
  config.gem 'diff-lcs', :lib => 'diff/lcs'
  config.gem 'haml'
  config.gem 'hpricot'
  config.gem 'json'
  config.gem 'less', :lib => false
  config.gem 'maruku'
  config.gem 'paperclip'
  config.gem 'super_exception_notifier', :version => '~> 2.0.0', :lib => 'exception_notifier'
  config.gem 'versionomy'
  config.gem 'warden'
  config.gem 'will_paginate'

  # Test libraries
  if RAILS_ENV == 'test'
    config.gem 'factory_girl', :lib => false
    config.gem 'remarkable_activerecord', :lib => false
    config.gem 'remarkable_rails', :lib => false
    config.gem 'rspec', :lib => false
    config.gem 'rspec-rails', :lib => false
  end
  if ENV['NEWRELIC']
    # Provide profiling information at URI '/newrelic' if app started with `NEWRELIC=1 ./script/server`
    config.gem 'newrelic_rpm'
  end
  
  # Libraries
  require 'zlib'

  # Local libraries
  require 'lib/defer_proxy'

  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Observers, which watch for changes to model objects
  config.active_record.observers = :cache_observer

  # Setup cache
  require 'rails_cache_configurator'
  RailsCacheConfigurator.apply(config)
end
