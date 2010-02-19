require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReleasesController do

  describe "#find" do

    before do
      @user1 = Factory(:user)
      @mod1 = Factory(:mod, :owner_id => @user1.id, :owner_type => 'User')
    end

    context "without matching release" do
      context "using a simple version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json', :version => '1.1.0' }
        it "should respond with a 404" do
          response.response_code.should == 404
        end
      end
      context "using a complex version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json', :version => '> 1.0.0' }
        it "should respond with a 404" do
          response.response_code.should == 404
        end
      end
      context "without version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json' }
        it "should respond with a 404" do
          response.response_code.should == 404
        end
      end
    end

    context "with one matching release" do
      before do
        @release1 = Factory(:release, :version => '1.1.1', :mod_id => @mod1.id)
      end
      context "using a simple version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json', :version => '1.1.1' }
        it "should respond with the release" do
          response.should be_success
          response_json['version'].should == '1.1.1'
        end
      end
      context "using a complex version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json', :version => '> 1.0.0' }
        it "should respond with the release" do
          response.should be_success
          response_json['version'].should == '1.1.1'
        end
      end
      context "without version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json' }
        it "should respond with the release" do
          response.should be_success
          response_json['version'].should == '1.1.1'
        end
      end
    end

    context "with multiple matching releases" do
      before do
        @release1 = Factory(:release, :version => '1.2.0', :mod_id => @mod1.id)
        @release2 = Factory(:release, :version => '1.1.1', :mod_id => @mod1.id)
      end
      context "using a complex version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json', :version => '> 1.0.0' }
        it "should respond with the latest matching release" do
          response.should be_success
          response_json['version'].should == '1.2.0'
        end
      end
      context "without version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json' }
        it "should respond with the latest release" do
          response.should be_success
          response_json['version'].should == '1.2.0'
        end
      end
    end

  end

end
