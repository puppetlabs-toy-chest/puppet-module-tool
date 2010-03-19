require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mod do

  before(:each) do
    @valid_attributes = {
      :name => "foo"
    }
  end

  describe "checking uniqueness" do
    before do
      # The matcher needs an existing record
      Factory.create(:mod)
    end
    it { should validate_uniqueness_of(:name).scoped_to([:owner_id, :owner_type]) }
  end

  describe "adding a watch" do
    before do
      @user = Factory(:user)
      @mod = Factory(:mod)
    end
    it "should add a watched mod" do
      @user.watches.create(:mod_id => @mod.id)
      @mod.watchers.should include(@user)
    end
  end


  it { should validate_format_of(:name).with('foo') }
  it { should validate_format_of(:name).not_with('bad_char').with_message(/alphanumeric/) }
  it { should validate_format_of(:name).not_with('1').with_message(/2 or more/) }

  it { should validate_format_of(:project_url).not_with('foo').with_message(/not appear to be valid/) }
  it { should validate_format_of(:project_url).with('http://github.com/bar/foo') } 
  it { should validate_format_of(:project_url).with('https://github.com/bar/foo') }
    
end
