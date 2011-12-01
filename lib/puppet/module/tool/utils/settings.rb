module Puppet::Module::Tool::Utils

  # = Settings
  #
  # This module contains methods for interacting with Puppet's settings files.
  module Settings

    def prepare_settings(options = {})
      require 'puppet/util/run_mode'

      if options[:config]
        Puppet.settings.send(:set_value, :config, options[:config], :cli)
      end

      # in order to read the master's modulepath
      change_settings_used(:master)

      define_settings

      if options[:install_dir]
        Puppet.settings.send(:set_value, :puppet_module_install_dir, options[:install_dir], :cli)
      end

      change_settings_used(:puppet_module)
      Puppet.settings.use(:puppet_module)

      [:puppet_module_repository].each do |key|
        if options[key]
          Puppet.settings.send(:set_value, key, options[key], :cli)
        end
      end

    end

    private

    def define_settings
      # Puppet defaults can only be set once
      return if @defaults_set

      Puppet.setdefaults(:puppet_module,
        :puppet_module_repository  => [
          Puppet::Module::Tool::REPOSITORY_URL,
          "The module repository"
        ],
        :puppet_module_working_dir => [
          '$vardir/puppet-module',
          "The directory into which module tool data is stored"
        ],
        :puppet_module_install_dir => [
          Puppet.settings[:modulepath].split(File::PATH_SEPARATOR).first,
          "The directory into which modules are installed"
        ]
      )
      @defaults_set = true
    end

    # The settings section we use when parsing is determined by the run_mode
    def change_settings_used(run_mode)
      # have to change the runmode so parse gets the right settings
      $puppet_application_mode = Puppet::Util::RunMode[run_mode]
      Puppet.settings.parse
    end

  end

end
