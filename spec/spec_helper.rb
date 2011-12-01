$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'puppet/module/tool'
require 'tmpdir'
require 'fileutils'

RSpec.configure do |config|
  config.mock_with :mocha

  config.before :each do
    Puppet.settings.stubs(:parse)
  end

  config.before :all do
    @tmp_confdir = Puppet[:confdir] = Dir.mktmpdir
    @tmp_vardir = Puppet[:vardir] = Dir.mktmpdir
  end

  config.after :all do
    FileUtils.rm_r [@tmp_confdir, @tmp_vardir]
  end
end

Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |support_file|
  require support_file
end
