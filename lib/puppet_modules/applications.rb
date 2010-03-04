module PuppetModules
  module Applications

    autoload :Application,       'puppet_modules/applications/application'
    autoload :Builder,           'puppet_modules/applications/builder'
    autoload :Freezer,           'puppet_modules/applications/freezer'
    autoload :Generator,         'puppet_modules/applications/generator'
    autoload :Installer,         'puppet_modules/applications/installer'
    autoload :Releaser,          'puppet_modules/applications/releaser'
    autoload :Unreleaser,        'puppet_modules/applications/unreleaser'
    autoload :Searcher,          'puppet_modules/applications/searcher'
    autoload :Cleaner,           'puppet_modules/applications/cleaner'
    
  end
end
