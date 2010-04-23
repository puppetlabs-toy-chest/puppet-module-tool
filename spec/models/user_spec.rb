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
