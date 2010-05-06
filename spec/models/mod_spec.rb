# == Schema Information
# Schema version: 20100320030102
#
# Table name: mods
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  namespace_id     :integer
#  description      :text
#  created_at       :datetime
#  updated_at       :datetime
#  project_url      :string(255)
#  address          :string(255)
#  owner_type       :string(255)
#  owner_id         :integer
#  project_feed_url :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mod do

  describe "validations" do
    should_allow_values_for     :name, 'foo'
    should_not_allow_values_for :name, 'bad_char', :message => /alphanumeric/
    should_not_allow_values_for :name, '1', :message => /2 or more/

    should_not_allow_values_for :project_url, 'foo', :message => /not appear to be valid/
    should_allow_values_for     :project_url, 'http://github.com/bar/foo'
    should_allow_values_for     :project_url, 'https://github.com/bar/foo'

    it "should validate uniqueness" do
      Factory :mod
      should validate_uniqueness_of :name, :scope => [:owner_id, :owner_type]
    end
  end

  describe "full_name" do
    it "should have username and mod name" do
      mod = Factory :mod

      mod.full_name.should == "#{mod.owner.username}/#{mod.name}"
    end
  end

  describe "to_param" do
    it "should be the mod name" do
      mod = Factory :mod
      
      mod.to_param.should == mod.name
    end
  end
  
  describe "version" do
    before :each do
      @mod = Factory :mod
    end
    
    describe "without releases" do
      it "should not have a version" do
        @mod.version.should be_nil
      end
    end

    describe "with a single release" do
      before do
        @release = Factory :release, :mod => @mod
      end

      it "should have the one version released" do
        @mod.version.should == @release.version
      end
    end

    describe "with multiple releases" do
      before do
        @release1 = Factory :release, :mod => @mod, :version => '2.3.4'
        @release2 = Factory :release, :mod => @mod, :version => '2.3.5'
      end

      it "should have latest version released" do
        @mod.version.should == @release2.version
      end

      it "should have releases in order" do
        @mod.releases.ordered.should == [@release2, @release1]
      end
    end

  end

  # TODO Implement Watches
=begin
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
=end
end
