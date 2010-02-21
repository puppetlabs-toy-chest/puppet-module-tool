module PuppetModules
  module Applications

    autoload :Application,       'puppet_modules/applications/application'
    autoload :CLI,               'puppet_modules/applications/cli'
    autoload :Builder,           'puppet_modules/applications/builder'
    autoload :MetadataGenerator, 'puppet_modules/applications/metadata_generator'
    autoload :Installer,         'puppet_modules/applications/installer'
    autoload :Releaser,          'puppet_modules/applications/releaser'
    
  end
end
