require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModsController do

  describe "#index" do

    context "via JSON, querying" do

      before do
        @mod1 = Factory(:mod, :name => 'foo')
        @mod2 = Factory(:mod, :name => 'bar', :namespace => @mod1.namespace)
        get :index, :q => @mod1.namespace.address
      end

      it "should return JSON" do
        response.should be_success
        doc = JSON.parse(response.body)
        doc.should be_a_kind_of(Array)
      end

    end

  end

  describe "#show" do

    context "with a valid address" do
      before do
        @mod1 = Factory(:mod, :name => 'foo')
        get :show, :id => @mod1.to_param
      end
      it "should find the module" do
        response.should be_success
      end
    end
    context "with an invalid address" do
      before do
        get :show, :id => 'this-doesnot-exist'
      end
      it "should return a 404" do
        response.response_code.should == 404
      end      
    end

  end

end
