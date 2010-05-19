require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReleasesController do

  describe "#new" do
    describe "when anonymous" do
      it "should forbid access" do
        mod = Factory :mod
        get :new, :user_id => mod.owner.to_param, :mod_id => mod.to_param

        response_should_redirect_to_login
      end
    end

    describe "when logged in" do
      before do
        @mod = Factory :mod
        @owner = @mod.owner
        @other_user = Factory :user
      end

      it "should allow user to see new release form for their own module" do
        sign_in @owner
        get :new, :user_id => @owner.to_param, :mod_id => @mod.to_param

        response.should be_success
        flash[:error].should be_nil
        assigns[:mod].should == @mod
        assigns[:release].should be_a_new_record
      end

      it "should not allow user to see new release form  for another's module" do
        sign_in @other_user
        get :new, :user_id => @owner.to_param, :mod_id => @mod.to_param

        response_should_be_forbidden
      end

      it "should not allow user to see new release form for an invalid module" do
        sign_in @owner
        get :new, :user_id => @owner.to_param, :mod_id => "invalid_module"

        response_should_be_not_found
      end
    end
  end

  describe "#create" do
    describe "when anonymous" do
      it "should forbid access" do
        mod = Factory :mod
        post :create, :user_id => mod.owner.to_param, :mod_id => mod.to_param

        response_should_redirect_to_login
      end
    end

    describe "when logged in" do
      before do
        @mod = Factory :mod
        @owner = @mod.owner
        @other_user = Factory :user
        @attributes = Factory.attributes_for :release, :mod => @mod
      end


      describe "allow user to create release for their module" do
        it "using HTML" do
          sign_in @owner
          post :create, :user_id => @owner.to_param, :mod_id => @mod.to_param, :release => @attributes

          release = assigns[:release]
          release.should_not be_a_new_record
          response.should redirect_to(user_mod_release_path(release.owner, release.mod, release))
        end

        it "using JSON" do
          sign_in @owner
          post :create, :user_id => @owner.to_param, :mod_id => @mod.to_param, :release => @attributes, :format => "json"

          release = assigns[:release]
          release.should_not be_a_new_record
          data = response_json
          data['version'].should == @attributes[:version]
        end
      end

      it "should not allow user to create release with invalid attachment" do
        sign_in @owner
        post :create, :user_id => @owner.to_param, :mod_id => @mod.to_param, :release => @attributes.merge(:file => "invalid_file.txt")

        response.should be_success
        flash[:error].should_not be_nil
        assigns[:mod].should == @mod
        assigns[:release].should be_a_new_record
      end

      describe "should not allow user to create release with invalid attributes" do
        it "using HTML" do
          attributes = @attributes.merge(:version => nil)
          sign_in @owner
          post :create, :user_id => @owner.to_param, :mod_id => @mod.to_param, :release => attributes

          response.should be_success
          flash[:error].should_not be_nil
          assigns[:mod].should == @mod
          assigns[:release].should be_a_new_record
        end

        it "using JSON" do
          attributes = @attributes.merge(:version => nil)
          sign_in @owner
          post :create, :user_id => @owner.to_param, :mod_id => @mod.to_param, :release => attributes, :format => "json"

          response.should be_error
          assigns[:mod].should == @mod
          assigns[:release].should be_a_new_record
          data = response_json
          data['error'].should_not be_blank
        end
      end

      it "should not allow user to create release for another's module" do
        sign_in @other_user
        post :create, :user_id => @owner.to_param, :mod_id => @mod.to_param, :release => @attributes

        response_should_be_forbidden
      end

      it "should not allow user to create release for an invalid module" do
        sign_in @owner
        post :create, :user_id => @owner.to_param, :mod_id => "invalid_module", :release => @attributes

        response_should_be_not_found
      end
    end
  end

  describe "#destroy" do
    before do
      @release = Factory :release
      @mod = @release.mod
      @owner = @mod.owner
      @other_user = Factory :user
    end

    describe "when anonymous" do
      it "should refuse and demand a login" do
        delete :destroy, :user_id => @owner.to_param, :mod_id => @mod.to_param, :id => @release.to_param

        response_should_redirect_to_login
        Release.exists?(@release.id).should be_true
      end
    end

    describe "when logged-in" do
      describe "should allow owner to delete a release" do
        it "using HTML" do
          sign_in @owner
          delete :destroy, :user_id => @owner.to_param, :mod_id => @mod.to_param, :id => @release.to_param

          response.should redirect_to module_path(@owner, @mod)
          Release.exists?(@release.id).should be_false
        end

        it "using JSON" do
          sign_in @owner
          delete :destroy, :user_id => @owner.to_param, :mod_id => @mod.to_param, :id => @release.to_param, :format => "json"

          response.should be_success
          data = response_json
          data.should be_a_kind_of(Hash)
          Release.exists?(@release.id).should be_false
        end
      end

      it "should allow an admin to delete another's release" do
        admin = Factory :admin
        sign_in admin

        delete :destroy, :user_id => @owner.to_param, :mod_id => @mod.to_param, :id => @release.to_param

        response.should redirect_to module_path(@owner, @mod)
        Release.exists?(@release.id).should be_false
      end

      it "should not allow a user to delete another's release" do
        sign_in @other_user
        delete :destroy, :user_id => @owner.to_param, :mod_id => @mod.to_param, :id => @release.to_param

        response_should_be_forbidden
        Release.exists?(@release.id).should be_true
      end
    end

  end

  describe "#show" do
    it "should display a valid release" do
      release = Factory :release
      get :show, :user_id => release.mod.owner.to_param, :mod_id => release.mod.to_param, :id => release.to_param

      response.should be_success
      flash[:error].should be_nil
      assigns[:release].should == release
    end

    it "should fail on an invalid release" do
      mod = Factory :mod
      get :show, :user_id => mod.owner.to_param, :mod_id => mod.to_param, :id => "invalid_release"

      response_should_be_not_found
    end

    it "should fail on an invalid module" do
      user = Factory :user
      get :show, :user_id => user.to_param, :mod_id => "invalid_mod", :id => "invalid_release"

      response_should_be_not_found
    end

    it "should fail on an invalid user" do
      get :show, :user_id => "invalid_user", :mod_id => "invalid_mod", :id => "invalid_release"
    end
  end

  describe "#find" do

    before do
      @user1 = Factory(:user)
      @mod1 = Factory(:mod, :owner_id => @user1.id, :owner_type => 'User')
    end

    context "without a module" do
      it "should respond with a 404" do
        get :find, :mod_id => "invalid_module", :user_id => @user1.to_param, :format => 'json'

        response_should_be_not_found
      end
    end

    context "without matching release" do
      context "using a simple version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json', :version => '1.1.0' }
        it "should respond with a 404" do
          response_should_be_not_found
        end
      end
      context "using a complex version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json', :version => '> 1.0.0' }
        it "should respond with a 404" do
          response_should_be_not_found
        end
      end
      context "without version requirement" do
        before { get :find, :mod_id => @mod1.to_param, :user_id => @user1.to_param, :format => 'json' }
        it "should respond with a 404" do
          response_should_be_not_found
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

  describe "utilities" do
    describe "#can_change?" do
      describe "with an existing record" do
        before do
          @release = Factory :release
          controller.instance_variable_set(:@release, @release)
          controller.instance_variable_set(:@release_found, true)
        end

        it "should be true if user is allowed to change release" do
          @release.should_receive(:can_be_changed_by?).and_return(true)

          controller.send(:can_change?).should be_true
        end

        it "should not be true if user isn't allowed to change release" do
          @release.should_receive(:can_be_changed_by?).and_return(false)

          controller.send(:can_change?).should_not be_true
        end
      end

      describe "with a new record" do
        before do
          @mod = Factory :mod
          controller.instance_variable_set(:@mod, @mod)
          controller.instance_variable_set(:@mod_found, true)

          @release = Factory.build :release, :mod => @mod
          controller.instance_variable_set(:@release, @release)
          controller.instance_variable_set(:@release_found, nil)
        end

        it "should be true if user is allowed to change module" do
          @mod.should_receive(:can_be_changed_by?).and_return(true)

          controller.send(:can_change?).should be_true
        end

        it "should not be true if user is not allowed to change module" do
          @mod.should_receive(:can_be_changed_by?).and_return(false)

          controller.send(:can_change?).should_not be_true
        end
      end

      describe "without a record" do
        it "should not be true if no module found" do
          controller.instance_variable_set(:@mod_found, false)

          controller.send(:can_change?).should_not be_true
        end

        it "should not be true if no release found" do
          controller.instance_variable_set(:@release_found, false)
          controller.instance_variable_set(:@mod_found, true)

          controller.send(:can_change?).should_not be_true
        end
      end
    end
  end

end
