require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mod do

  before(:each) do
    @valid_attributes = {
      :name => "foo",
      :namespace_id => 1,
    }
  end

  describe "checking uniqueness" do
    before do
      # The matcher needs an existing record
      Factory.create(:mod)
    end
    it { should validate_uniqueness_of(:name).scoped_to(:namespace_id) }
  end
  it { should belong_to(:namespace) }
  it { should validate_presence_of(:namespace_id) }
  it { should validate_format_of(:name).with('foo') }
  it { should validate_format_of(:name).not_with('bad_char').with_message(/alphanumeric/) }
  it { should validate_format_of(:name).not_with('1').with_message(/2 or more/) }

  it { should validate_format_of(:source).not_with('foo').with_message(/location invalid/) }
  it { should validate_format_of(:source).not_with('foo.com').with_message(/location invalid/) }
  # TODO: support these using a public key, eventually
  it { should validate_format_of(:source).not_with('git@github.com:bar/foo').with_message(/location invalid/) }
  it { should validate_format_of(:source).not_with('git@github.com:bar/foo.git').with_message(/location invalid/) }

  it { should validate_format_of(:source).with('git://github.com/bar/foo.git') }
  it { should validate_format_of(:source).with('http://github.com/bar/foo.git') } 
  it { should validate_format_of(:source).with('https://github.com/bar/foo.git') }
 
  describe '#title' do

    describe 'after saving' do
      before do
        @mod = Factory(:mod)
      end
      
      it "should default the title attribute" do
        @mod.title.should == @mod.name.titleize
      end
    end
    
    describe 'before saving' do
      before do
        @mod = Factory(:mod)
      end
      
      it "should have a defaulted title attribute before saving" do
        @mod.title.should == @mod.name.titleize
      end
    end

  end

  describe "#full_name" do

    before do
      @mod = Factory(:mod)
    end

    it "should start with the namespace full_name" do
      @mod.full_name.should == "#{@mod.namespace.full_name}-#{@mod.name}"
    end

  end

  describe "#allows?" do

    before do
      @member = Factory(:ns_member)
      @mod = Factory(:mod, :namespace => @member.namespace)
      @other_user = Factory(:user)
    end

    it "should return true for users who have a related NamespaceMembership" do
      @mod.allows?(@member.user).should be_true
    end

    it "should return false for users who do not have a related NamespaceMembership" do
      @mod.allows?(@other_user).should be_false
    end

  end

  describe "#repo_path" do

    before do
      @member = Factory(:ns_member)
      @mod = Factory(:mod, :namespace => @member.namespace)
    end

    it "should be based on the full_name" do
      @mod.repo_path.should == "#{@mod.namespace.owner.name}/#{@mod.namespace.name}/#{@mod.name}"
    end
    
  end
    
end
