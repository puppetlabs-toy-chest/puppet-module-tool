module Puppet::Module::Tool
  module Applications

    require 'puppet/module/tool/applications/application'
    require 'puppet/module/tool/applications/builder'
    require 'puppet/module/tool/applications/checksummer'
    require 'puppet/module/tool/applications/cleaner'
    require 'puppet/module/tool/applications/freezer'
    require 'puppet/module/tool/applications/generator'
    require 'puppet/module/tool/applications/installer'
    require 'puppet/module/tool/applications/registrar'
    require 'puppet/module/tool/applications/releaser'
    require 'puppet/module/tool/applications/searcher'
    require 'puppet/module/tool/applications/unpacker'
    require 'puppet/module/tool/applications/unreleaser'
    
  end
end
