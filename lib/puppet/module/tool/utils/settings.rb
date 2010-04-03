module Puppet::Module::Tool::Utils::Settings

  def prepare_settings(options = {})
    return if @settings_prepared
    if options[:config]
      Puppet.settings.send(:set_value, :config, options[:config], :cli)
    end
    Puppet.setdefaults(:pmt,
                       :modulerepository => ['https://modules.puppetlabs.com',
                                             "The module repository"],
                       :pmtdir => ['$vardir/pmt', "The directory in which module tool data is stored"])
    
    Puppet.settings.use(:pmt)
    Puppet.settings.parse
    [:modulerepository].each do |key|
      if options[key]
        Puppet.settings.send(:set_value, key, options[key], :cli)
      end
    end
    @settings_prepared = true
  end
  
end
