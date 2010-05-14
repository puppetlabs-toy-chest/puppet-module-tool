# == Schema Information
# Schema version: 20100320030102
#
# Table name: users
#
#  id                   :integer         not null, primary key
#  username             :string(255)
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  confirmation_token   :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer         default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  display_name         :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "validations" do
    should_allow_values_for :username, 'foo'
    should_not_allow_values_for :username, 'bad|char', :message => /alphanumeric/
    should_not_allow_values_for :username, '12', :message => /3 or more/

    it "should validate uniqueness" do
      Factory :user
      should validate_uniqueness_of :username
    end
  end

  describe "can_be_changed_by?" do
    before do
      @user = Factory :user
      @other = Factory :user
      @admin = Factory :admin
    end

    it "should allow the owner" do
      @user.can_be_changed_by?(@user).should be_true
    end

    it "should allow an admin" do
      @user.can_be_changed_by?(@admin).should be_true
    end

    it "should not allow another user" do
      @user.can_be_changed_by?(@other).should_not be_true
    end

    it "should not allow an anonymous user" do
      @user.can_be_changed_by?(nil).should_not be_true
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
=end
end
