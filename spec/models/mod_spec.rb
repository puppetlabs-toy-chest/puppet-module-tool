require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mod do

  before(:each) do
    @valid_attributes = {
      :name => "foo"
    }
  end

  describe "validations" do
    it "should validate"

    # it { should validate_format_of(:name).with('foo') }
    # it { should validate_format_of(:name).not_with('bad_char').with_message(/alphanumeric/) }
    # it { should validate_format_of(:name).not_with('1').with_message(/2 or more/) }

    # it { should validate_format_of(:project_url).not_with('foo').with_message(/not appear to be valid/) }
    # it { should validate_format_of(:project_url).with('http://github.com/bar/foo') }
    # it { should validate_format_of(:project_url).with('https://github.com/bar/foo') }

    # it { should validate_uniqueness_of(:name).scoped_to([:owner_id, :owner_type]) }
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

  describe '#watchable_by?' do
    before do
      @owner = Factory(:user)
      @mod = Factory(:mod, :owner => @owner)
    end

    context "for the owner of the module" do
      it "should return false" do
        @mod.should_not be_watchable_by(@owner)
      end
    end

    context "for a different user" do
      before do
        @user = Factory(:user)
      end
      context "that is already watching the mod" do
        before do
          @user.watched_mods << @mod
        end
        it "should be true" do
          @mod.should be_watchable_by(@user)
        end
      end
      context "that is not already watching the mod" do
        it "should be true" do
          @mod.should be_watchable_by(@user)
        end
      end
    end
  end

  describe '#watched_by?' do
    before do
      @owner = Factory(:user)
      @mod = Factory(:mod, :owner => @owner)
      @user = Factory(:user)
    end
    context "for a user that is already watching the mod" do
      before do
        @user.watched_mods << @mod
      end
      it "should be true" do
        @mod.should be_watched_by(@user)
      end
    end
    context "for a user that is not already watching the mod" do
      it "should be false" do
        @mod.should_not be_watched_by(@user)
      end
    end
  end

end
