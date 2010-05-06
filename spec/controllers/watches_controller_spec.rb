require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WatchesController do
  # TODO Implement WatchesController
=begin
describe "#create" do

    before do
      @user = Factory(:user)
      @user.confirm!
      @owner = Factory(:user)
      sign_in @user
      @mod = Factory(:mod, :owner => @owner)
      post :create, :mod_id => @mod.id
    end

    it "adds a watch for the current user" do
      response.should redirect_to(module_path(@owner, @mod))
      @user.watched_mods.should include(@mod)
    end

  end
=end
end
