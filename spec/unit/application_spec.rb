require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Puppet::Module::Tool::Applications::Application do

  describe 'inherited classes' do

    before do
      @app = Class.new(described_class).new
      Puppet::Module::Tool.stubs(:prepare_settings)
      Puppet.stubs(:settings => {:puppet_module_repository => 'http://fake.modules.site.com'})
    end

    describe '#repository' do
      before do
        @url = 'http://fake.com'
        Puppet.settings.expects(:[]).with(:puppet_module_repository).returns(@url)
      end
      it "should use the :puppet_module_repository setting" do
        @app.repository.uri.should == URI.parse(@url)
      end
    end

  end

end
