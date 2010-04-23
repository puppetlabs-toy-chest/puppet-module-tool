require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe ".create" do
    it "should validate"
    #FIXME it { should validate_uniqueness_of(:username) }
    #FIXME it { should validate_format_of(:username).with('foo') }
    #FIXME it { should validate_format_of(:username).not_with('bad_char').with_message(/alphanumeric/) }
    #FIXME it { should validate_format_of(:username).not_with('12').with_message(/3 or more/) }

    before do
      @user = Factory(:user)
    end
  end

  describe "adding a watch" do
    before do
      @user = Factory(:user)
      @mod = Factory(:mod)
    end
    it "should add a watched mod" do
      @user.watches.create(:mod_id => @mod.id)
      @user.watched_mods.should include(@mod)
    end
  end

  describe '#watching?' do
    before do
      @user = Factory(:user)
      @mod = Factory(:mod)
    end

    context "for a mod that the user is watching" do
      before do
        @user.watches.create :mod => @mod
      end
      it "should be true" do
        @user.should be_watching(@mod)
      end
    end
    
    context "for a mod that the user is not watching" do
      it "should be false" do
        @user.should_not be_watching(@mod)
      end
    end
  end
  
end
