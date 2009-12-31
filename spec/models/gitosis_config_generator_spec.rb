require 'spec_helper'

describe Gitosis::ConfigGenerator do
  
  before do
    @mod = Factory(:mod, :namespace => Factory(:namespace))
    @user1 = Factory(:user, :public_key => 'fake')
    @user2 = Factory(:user)
    @user3 = Factory(:user)
    Factory(:ns_member, :user => @user1, :namespace => @mod.namespace)
    Factory(:ns_member, :user => @user2, :namespace => @mod.namespace)
    @config = Gitosis::ConfigGenerator.new.generate
  end

  describe "base settings" do

    it "should include a [gitosis] section" do
      @config.should include("[gitosis]")
    end

    it "should have a gitweb setting" do
      @config.should include("gitweb =")
    end

    it "should have a daemon setting" do
      @config.should include("daemon =")
    end

  end

  describe "groups" do

    it "should have a group for the namespace" do
      @config.should include("[group #{@mod.namespace.full_name}]")
    end

  end

  describe "writable repositoriess" do

    it "should have an entry for namespace modules" do
      @config.should include("writable = #{@mod.repo_path}")
    end
    
  end

  describe "members" do

    describe "users in namespace" do

      describe "that have public keys" do

        it "should include users in namespace " do
          @config.should =~ /members =.*?#{@user1.name}/
        end

      end

      describe "that do not have public keys" do

        it "should include users in namespace " do
          @config.should_not =~ /members =.*?#{@user2.name}/      
        end

      end
      
    end

    it "should not include users not in namespace" do
      @config.should_not =~ /members =.*?#{@user3.name}/
    end

  end
    
  
end
