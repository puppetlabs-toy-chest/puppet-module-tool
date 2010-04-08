$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'puppet/module/tool'
require 'spec'
require 'spec/autorun'

Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |support_file|
  require support_file
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
