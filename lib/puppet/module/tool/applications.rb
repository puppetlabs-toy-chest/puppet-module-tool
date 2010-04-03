module Puppet::Module::Tool
  module Applications

    autoload :Application,       'puppet/module/tool/applications/application'
    autoload :Builder,           'puppet/module/tool/applications/builder'
    autoload :Checksummer,       'puppet/module/tool/applications/checksummer'
    autoload :Cleaner,           'puppet/module/tool/applications/cleaner'
    autoload :Freezer,           'puppet/module/tool/applications/freezer'
    autoload :Generator,         'puppet/module/tool/applications/generator'
    autoload :Installer,         'puppet/module/tool/applications/installer'
    autoload :Registrar,         'puppet/module/tool/applications/registrar'
    autoload :Releaser,          'puppet/module/tool/applications/releaser'
    autoload :Searcher,          'puppet/module/tool/applications/searcher'
    autoload :Unpacker,          'puppet/module/tool/applications/unpacker'
    autoload :Unreleaser,        'puppet/module/tool/applications/unreleaser'
    
  end
end
