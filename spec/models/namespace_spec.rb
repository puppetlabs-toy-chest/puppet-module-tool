require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Namespace do

  before(:each) do
    @owner = Factory.create(:user)
    @valid_attributes = {
      :name => "aname",
      :owner_id => @owner.id,
      :owner_type => @owner.class.name
    }
  end

  it { should belong_to(:owner) }
  it { should validate_presence_of(:owner_id) }
  it { should validate_presence_of(:owner_type) }
  it { should validate_format_of(:name).with('foo') }
  it { should validate_format_of(:name).not_with('bad_char').with_message(/alphanumeric/) }
  it { should validate_format_of(:name).not_with('1').with_message(/2 or more/) }

  describe '.create' do

    before do
      @namespace = Namespace.create!(@valid_attributes)
    end
    
    it "should default the title attribute" do
      @namespace.title.should == @namespace.name.titleize
    end

    it { should validate_uniqueness_of(:name).scoped_to(:owner_id, :owner_type) }

  end

  describe '.new' do

    it "should have a defaulted title attribute before saving" do
      @namespace = Namespace.new(@valid_attributes)
      @namespace.title.should == @namespace.name.titleize
    end

  end

  describe "#full_name" do

    before do
      @namespace = Namespace.create!(@valid_attributes)
    end

    it "should include the owner name" do
      @namespace.full_name.should == 'bruce-aname'
    end

  end

  describe "#default?" do

    describe "when the name is 'default'" do
      before { @namespace = Namespace.create!(@valid_attributes.merge(:name => 'default')) }
      it "should be true" do
        @namespace.should be_default
      end
    end

    describe "when the name is not 'default'" do
      before { @namespace = Namespace.create!(@valid_attributes.merge(:name => 'notdefault')) }
      it "should be false" do
        @namespace.should_not be_default
      end
    end
    
  end
    
end
