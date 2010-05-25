require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModsController do

  describe "#index" do

    context "with users and modules" do

      before do
        @user1 = Factory(:user)
        @user2 = Factory(:user)

        @user1mod_with_release    = Factory(:mod, :name => 'foo', :owner => @user1)
        @user2mod_with_release    = Factory(:mod, :name => 'bar', :owner => @user2)
        @user2mod_without_release = Factory(:mod, :name => 'baz', :owner => @user2)

        @mod1rel1 = Factory(:release, :mod => @user1mod_with_release)
        @mod2rel1 = Factory(:release, :mod => @user2mod_with_release)
      end

      context "for all mods" do

        it "should render all mods with releases for all users" do
          get :index

          response.should be_success
          assigns[:mods].should include @user1mod_with_release
          assigns[:mods].should include @user2mod_with_release
          assigns[:mods].should_not include @user2mod_without_release
        end

        it "should render mods with releases for all users matching search" do
          get :index, :q => "foo"

          response.should be_success
          assigns[:mods].should == [@user1mod_with_release]
        end

      end

      context "for user's mods" do

        # CURRENTLY: We redirect /username/modules back to /username since these both display modules.
        it "should redirect to user's page" do
          get :index, :user_id => @user1.to_param, :format => "html"

          response.should redirect_to(user_path @user1)
        end

        # PREVIOUSLY: We rendered slightly different pages for these, which was confusing.
=begin
        it "should render all mods with releases for a user" do
          get :index, :user_id => @user1.to_param, :format => "html"

          response.should be_success
          assigns[:mods].should include @user1mod_with_release
          assigns[:mods].should_not include @user2mod_with_release
          assigns[:mods].should_not include @user2mod_without_release
        end
=end

        it "should display error if user doesn't exist" do
          get :index, :user_id => "invalid_user_name"

          response_should_be_not_found
        end

      end

    end

    context "with JSON query" do

      before do
        @release = Factory :release
        @mod = @release.mod
        @user = @release.owner
      end

      it "should return mods" do
        get :index, :format => 'json'

        response.should be_success
        data = response_json
        data.should be_a_kind_of(Array)
        item = data.first
        item['name'].should        == @mod.name
        item['version'].should     == @release.version
        item['full_name'].should   == @mod.full_name
        item['project_url'].should == @mod.project_url
      end

    end

  end

  describe "#new" do
    it "should show new record form when logged-in" do
      @user = Factory(:user)

      sign_in @user
      get :new

      response.should be_success
      assigns[:mod].should be_a_new_record
    end

    it "should not allow new record form unless logged-in" do
      get :new

      response.should be_redirect
      assigns[:mod].should be_nil
    end
  end

  describe "#create" do
    context "when logged-in" do
      before do
        @user = Factory(:user)
        sign_in @user
      end

      it "should create a record without owner in route" do
        attributes = Factory.attributes_for(:mod, :owner => nil)

        post :create, "mod" => attributes

        response.should be_redirect
        flash[:error].should be_nil
        assigns[:mod].should be_valid
      end

      it "should create a record with owner in route" do
        attributes = Factory.attributes_for(:mod, :owner => nil)

        post :create, :user_id => @user.to_param, "mod" => attributes

        response.should be_redirect
        flash[:error].should be_nil
        assigns[:mod].should be_valid
      end

      it "should not create an invalid record" do
        attributes = Factory.attributes_for(:mod, :owner => nil, :name => nil)

        post :create, "mod" => attributes

        response.should be_success
        flash[:error].should_not be_blank
        assigns[:mod].should_not be_valid
      end
    end

    it "should not allow anonymous user to create a record" do
      attributes = Factory.attributes_for(:mod, :owner => nil)

      post :create, "mod" => attributes

      response_should_redirect_to_login
    end
  end

  describe "#edit" do
    before do
      @user1 = Factory(:user)
      @user1mod = Factory(:mod, :owner => @user1)

      @user2 = Factory(:user)
      @user2mod = Factory(:mod, :owner => @user2)
    end

    context "when logged-in" do
      it "should allow owner to edit their module" do
        sign_in @user1
        get :edit, :user_id => @user1.to_param, :id => @user1mod.to_param

        response.should be_success
        assigns[:mod].should == @user1mod
      end

      it "should allow an admin to edit another's module" do
        admin = Factory :admin
        sign_in admin
        get :edit, :user_id => @user1.to_param, :id => @user1mod.to_param

        response.should be_success
        assigns[:mod].should == @user1mod
      end

      it "should not allow a user to edit another's module" do
        sign_in @user2
        get :edit, :user_id => @user1.to_param, :id => @user1mod.to_param

        response_should_be_forbidden
      end

      it "should display error if trying to edit an invalid module" do
        sign_in @user1
        get :edit, :user_id => @user1.to_param, :id => "invalid_module_name"

        response_should_be_not_found
      end
    end

    context "when anonymous" do
      it "should not allow anonymous user to edit a module" do
        get :edit, :user_id => @user1.to_param, :id => @user1mod.to_param

        response_should_redirect_to_login
      end
    end
  end

  describe "#update" do
    before do
      @user1 = Factory(:user)
      @user1mod = Factory(:mod, :owner => @user1)

      @user2 = Factory(:user)
      @user2mod = Factory(:mod, :owner => @user2)

      @attributes = Factory.attributes_for(:mod, :owner => nil)
    end

    context "when logged-in" do
      it "should allow owner to update their module" do
        sign_in @user1
        put :update, :user_id => @user1.to_param, :id => @user1mod.to_param, :mod => @attributes

        response.should be_redirect
        flash[:error].should be_blank
        assigns[:mod].should be_valid
        assigns[:mod].should == @user1mod
        assigns[:mod].name.should == @attributes[:name]
      end

      it "should allow an admin to update another's module" do
        admin = Factory :admin
        sign_in admin
        put :update, :user_id => @user1.to_param, :id => @user1mod.to_param, :mod => @attributes

        response.should be_redirect
        flash[:error].should be_blank
        assigns[:mod].should be_valid
        assigns[:mod].should == @user1mod
        assigns[:mod].name.should == @attributes[:name]
      end

      it "should display error if update was invalid" do
        invalid_name = "!" # Name violates validation rules
        attributes = @attributes.dup
        attributes[:name] = invalid_name

        sign_in @user1
        put :update, :user_id => @user1.to_param, :id => @user1mod.to_param, :mod => attributes

        response.should be_success
        flash[:error].should_not be_blank
        assigns[:mod].should_not be_valid
        assigns[:mod].should == @user1mod
        assigns[:mod].name.should == invalid_name
      end

      it "should not allow a user to update another's module" do
        sign_in @user2
        get :update, :user_id => @user1.to_param, :id => @user1mod.to_param

        response_should_be_forbidden
      end

      it "should display error if trying to update an invalid module" do
        sign_in @user1
        get :update, :user_id => @user1.to_param, :id => "invalid_module_name"

        response_should_be_not_found
      end
    end

    context "when anonymous" do
      it "should not allow anonymous user to edit a module" do
        get :edit, :user_id => @user1.to_param, :id => @user1mod.to_param

        response.should be_redirect
        flash[:error].should be_blank
      end
    end
  end

  describe "#show" do
    it "should show a user's module that has releases" do
      release = Factory :release
      user = release.owner
      mod = release.mod

      get :show, :user_id => user.to_param, :id => mod.to_param

      response.should be_success
      assigns[:user].should == user
      assigns[:mod].should == mod
      flash[:error].should be_blank
    end

    it "should show a user's module that has no releases" do
      user = Factory(:user)
      mod1 = Factory(:mod, :name => 'foo', :owner => user)

      get :show, :user_id => user.to_param, :id => mod1.to_param

      response.should be_success
      assigns[:user].should == user
      assigns[:mod].should == mod1
      flash[:error].should be_blank
    end

    it "should display error if module doesn't exist" do
      user = Factory(:user)

      get :show, :user_id => user.to_param, :id => "invalid_module_name"

      response_should_be_not_found
    end

    it "should display error if user doesn't exist" do
      get :show, :user_id => "invalid_user_name", :id => "invalid_module_name"

      response_should_be_not_found
    end

    it "should return record as JSON" do
      release = Factory :release
      mod = release.mod
      user = release.owner

      get :show, :user_id => user.to_param, :id => mod.to_param, :format => 'json'

      item = response_json
      item.should be_a_kind_of(Hash)
      item['name'].should        == mod.name
      item['version'].should     == release.version
      item['full_name'].should   == mod.full_name
      item['project_url'].should == mod.project_url
    end
  end

  describe "#destroy" do
    before do
      @user1 = Factory(:user)
      @user1mod = Factory(:mod, :owner => @user1)

      @user2 = Factory(:user)
    end

    context "when logged-in" do
      it "should allow a user to delete their module" do
        sign_in @user1

        delete :destroy, :user_id => @user1.to_param, :id => @user1mod.to_param

        response.should redirect_to(vanity_path(@user1))
        Mod.exists?(@user1mod.id).should be_false
      end

      it "should allow an admin to delete another's module" do
        admin = Factory :admin
        sign_in admin

        delete :destroy, :user_id => @user1.to_param, :id => @user1mod.to_param

        response.should redirect_to(vanity_path(@user1))
        Mod.exists?(@user1mod.id).should be_false
      end

      it "should not allow a user to delete another's module" do
        sign_in @user2

        delete :destroy, :user_id => @user1.to_param, :id => @user1mod.to_param

        response_should_be_forbidden
      end
    end

    context "when anonymous" do
      it "should not allow destroy" do
        delete :destroy, :user_id => @user1.to_param, :id => @user1mod.to_param

        response_should_redirect_to_login
        Mod.exists?(@user1mod.id).should be_true
      end
    end
  end

end
