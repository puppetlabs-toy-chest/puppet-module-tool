class PuppetModules::Configuration::DSL

  def initialize(configuration)
    @configuration = configuration
  end

  def repository(url)
    @configuration.repository = url
  end
  
end
