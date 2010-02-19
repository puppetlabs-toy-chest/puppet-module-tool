require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModsController do

  describe "#index" do

    context "via JSON, querying" do

      before do
        @user = Factory(:user)
        @mod1 = Factory(:mod, :name => 'foo', :owner_id => @user.id, :owner_type => 'User')
        get :index
      end

      it "should return JSON" do
        response.should be_success
        doc = JSON.parse(response.body)
        doc.should be_a_kind_of(Array)
      end

    end

  end


end
