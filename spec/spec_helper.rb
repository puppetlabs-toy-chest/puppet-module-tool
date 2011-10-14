$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'

require 'puppet/module/tool'

Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |support_file|
  require support_file
end

RSpec.configure do |config|
  config.mock_with :mocha
end
