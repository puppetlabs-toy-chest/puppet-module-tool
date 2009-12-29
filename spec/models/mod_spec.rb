require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mod do

  before(:each) do
    @valid_attributes = {
      :name => "foo",
      :namespace_id => 1,
    }
    @mod = Mod.new(@valid_attributes)
    @mod.stubs :namespace => mock('namespace', :full_name => 'bruce-aname')
  end

  it { should belong_to(:namespace) }
  it { should validate_presence_of(:namespace_id) }
  it { should validate_format_of(:name).with('foo') }
  it { should validate_format_of(:name).not_with('bad_char').with_message(/alphanumeric/) }
  it { should validate_format_of(:name).not_with('1').with_message(/2 or more/) }

  describe '.create' do

    before do
      @mod = Mod.create!(@valid_attributes)
    end
    
    it "should default the title attribute" do
      @mod.title.should == @mod.name.titleize
    end

    it { should validate_uniqueness_of(:name).scoped_to(:namespace_id) }

  end

  describe '.new' do

    it "should have a defaulted title attribute before saving" do
      @mod = Mod.new(@valid_attributes)
      @mod.title.should == @mod.name.titleize
    end

  end

  describe "#full_name" do

    before do
      @mod = Mod.create!(@valid_attributes)
      @mod.stubs :namespace => mock('ns', :full_name => 'bruce-aname')
    end

    it "should start with the namespace full_name" do
      @mod.full_name.should == 'bruce-aname-foo'
    end

  end
    
end
