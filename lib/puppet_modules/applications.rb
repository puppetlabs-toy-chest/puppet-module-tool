module PuppetModules
  module Applications

    autoload :Application,       'puppet_modules/applications/application'
    autoload :Builder,           'puppet_modules/applications/builder'
    autoload :Checksummer,       'puppet_modules/applications/checksummer'
    autoload :Cleaner,           'puppet_modules/applications/cleaner'
    autoload :Freezer,           'puppet_modules/applications/freezer'
    autoload :Generator,         'puppet_modules/applications/generator'
    autoload :Installer,         'puppet_modules/applications/installer'
    autoload :Registrar,         'puppet_modules/applications/registrar'
    autoload :Releaser,          'puppet_modules/applications/releaser'
    autoload :Searcher,          'puppet_modules/applications/searcher'
    autoload :Unpacker,          'puppet_modules/applications/unpacker'
    autoload :Unreleaser,        'puppet_modules/applications/unreleaser'
    
  end
end
