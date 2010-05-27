module Puppet::Module::Tool::Utils

  # = Settings
  #
  # This module contains methods for interacting with Puppet's settings files.
  module Settings

    def prepare_settings(options = {})
      return if @settings_prepared

      if options[:config]
        Puppet.settings.send(:set_value, :config, options[:config], :cli)
      end

      Puppet.setdefaults(:puppet_module,
        :puppet_module_repository => [Puppet::Module::Tool::REPOSITORY_URL, "The module repository"],
        :puppet_module_working_dir => ['$vardir/puppet-module', "The directory in which module tool data is stored"])

      Puppet::Module::Tool.working_dir.mkpath

      Puppet.settings.use(:puppet_module)

      Puppet.settings.parse

      [:puppet_module_repository].each do |key|
        if options[key]
          Puppet.settings.send(:set_value, key, options[key], :cli)
        end
      end

      @settings_prepared = true
    end

  end
  
end
