require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do

  describe "#home" do
    it "should redirect to root" do
      get :home

      response.should redirect_to(root_path)
    end
  end

  describe "#root" do
    it "should render page" do
      get :root

      response.should be_success
    end
  end
end
