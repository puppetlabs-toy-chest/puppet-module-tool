require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe ".authenticate" do
    before do
      @user = Factory.create(:user)
    end
    it "should authenticate" do
      User.authenticate('bruce', 'test').should == @user
    end
  end

end
