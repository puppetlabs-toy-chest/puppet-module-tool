require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  it { should have_many(:namespace_memberships) }
  it { should have_many(:namespaces) }
  it { should validate_format_of(:username).with('foo') }
  it { should validate_format_of(:username).not_with('bad_char').with_message(/alphanumeric/) }
  it { should validate_format_of(:username).not_with('12').with_message(/3 or more/) }


  describe ".authenticate" do
    before do
      @user = Factory.create(:user)
    end
    it "should authenticate" do
      User.authenticate('bruce', 'test').should == @user
    end
  end

  describe ".create" do

    before do
      @user = Factory.create(:user)
    end

    it { should validate_uniqueness_of(:username) }

  end

end
