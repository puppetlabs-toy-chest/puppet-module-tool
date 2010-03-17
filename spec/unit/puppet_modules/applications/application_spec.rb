require 'pathname'
Pathname.new(__FILE__).realpath.ascend do |x|
  begin; require (x + 'spec_helper.rb'); break; rescue LoadError; end
end

describe PuppetModules::Applications::Application do
  
  describe '.requires' do
    it "should delegate to whiny_require" do
      described_class.expects(:whiny_require).with('foo', 'bar')
      described_class.requires('foo', 'bar')
    end
  end

  describe '.run' do
    it "should instantiate a new Application instance with the same arguments" do
      described_class.any_instance.expects(:run)
      instance = described_class.new
      described_class.expects(:new).with('foo', 'bar').returns(instance)
      described_class.run('foo', 'bar')
    end
  end

end
