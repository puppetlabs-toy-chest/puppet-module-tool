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

        it "should render all mods with releases for a user" do
          get :index, :user_id => @user1.name, :format => "html"

          response.should be_success
          assigns[:mods].should include @user1mod_with_release
          assigns[:mods].should_not include @user2mod_with_release
          assigns[:mods].should_not include @user2mod_without_release
        end

        it "should display error if user doesn't exist" do
          get :index, :user_id => "invalid_user_name"

          response.should be_success
          assigns[:user].should be_nil
          flash[:error].should_not be_blank
        end

      end

    end

    context "via JSON, querying" do

      before do
        @user = Factory(:user)
        @mod1 = Factory(:mod, :name => 'foo', :owner => @user)
        get :index
      end

      it "should return JSON" do
        response.should be_success
        doc = JSON.parse(response.body)
        doc.should be_a_kind_of(Array)
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

      it "should create a record" do
        attributes = Factory.attributes_for(:mod, :owner => nil)

        post :create, "mod" => attributes

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
        get :edit, :user_id => @user1.name, :id => @user1mod.name

        response.should be_success
        assigns[:mod].should == @user1mod
      end

      it "should not allow a user to edit another's module" do
        sign_in @user2
        get :edit, :user_id => @user1.name, :id => @user1mod.name

        response.should be_redirect
        flash[:error].should_not be_blank
      end

      it "should display error if trying to edit an invalid module" do
        sign_in @user1
        get :edit, :user_id => @user1.name, :id => "invalid_module_name"

        response.should be_redirect
        flash[:error].should_not be_blank
      end
    end

    context "when anonymous" do
      it "should not allow anonymous user to edit a module" do
        get :edit, :user_id => @user1.name, :id => @user1mod.name

        response.should be_redirect
        flash[:error].should be_blank
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
        put :update, :user_id => @user1.name, :id => @user1mod.name, :mod => @attributes

        response.should be_redirect
        flash[:error].should be_blank
        assigns[:mod].should be_valid
        assigns[:mod].should == @user1mod
        assigns[:mod].name.should == @attributes[:name]
      end

      it "should display error if update was invalid" do
        attributes = @attributes.dup
        attributes[:name] = "!" # Name violates validation rules

        sign_in @user1
        put :update, :user_id => @user1.name, :id => @user1mod.name, :mod => attributes

        response.should be_success
        flash[:error].should_not be_blank
        assigns[:mod].should_not be_valid
        assigns[:mod].should == @user1mod
        assigns[:mod].name.should == attributes[:name]
      end

      it "should not allow a user to update another's module" do
        sign_in @user2
        get :update, :user_id => @user1.name, :id => @user1mod.name

        response.should be_redirect
        flash[:error].should_not be_blank
      end

      it "should display error if trying to update an invalid module" do
        sign_in @user1
        get :update, :user_id => @user1.name, :id => "invalid_module_name"

        response.should be_redirect
        flash[:error].should_not be_blank
      end
    end

    context "when anonymous" do
      it "should not allow anonymous user to edit a module" do
        get :edit, :user_id => @user1.name, :id => @user1mod.name

        response.should be_redirect
        flash[:error].should be_blank
      end
    end
  end

  describe "#show" do
    it "should show a user's module that has releases" do
      @user = Factory(:user)
      @mod1 = Factory(:mod, :name => 'foo', :owner => @user)
      @release1 = Factory(:release, :mod => @mod1)

      get :show, :user_id => @user.name, :id => @mod1.name

      response.should be_success
      assigns[:user].should == @user
      assigns[:mod].should == @mod1
      flash[:error].should be_blank
    end

    it "should show a user's module that has no releases" do
      @user = Factory(:user)
      @mod1 = Factory(:mod, :name => 'foo', :owner => @user)

      get :show, :user_id => @user.name, :id => @mod1.name

      response.should be_success
      assigns[:user].should == @user
      assigns[:mod].should == @mod1
      flash[:error].should be_blank
    end

    it "should display error if module doesn't exist" do
      @user = Factory(:user)

      get :show, :user_id => @user.name, :id => "invalid_module_name"

      response.should redirect_to(vanity_path(@user))
      assigns[:user].should == @user
      assigns[:mod].should be_nil
      flash[:error].should_not be_blank
    end

    it "should display error if user doesn't exist" do
      get :show, :user_id => "invalid_user_name", :id => "invalid_module_name"

      response.should redirect_to(mods_path)
      assigns[:user].should be_nil
      assigns[:mod].should be_nil
      flash[:error].should_not be_blank
    end

    describe "#edit" do
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

        delete :destroy, :user_id => @user1.name, :id => @user1mod.name

        response.should redirect_to(vanity_path(@user1))
        Mod.exists?(@user1mod.id).should be_false
      end

      it "should not allow a user to delete another's module" do
        sign_in @user2

        delete :destroy, :user_id => @user1.name, :id => @user1mod.name

        response.should redirect_to(module_path(@user1, @user1mod))
        Mod.exists?(@user1mod.id).should be_true
      end
    end

    context "when anonymous" do
      it "should not allow destroy" do
        delete :destroy, :user_id => @user1.name, :id => @user1mod.name

        response.should redirect_to(unauthenticated_session_path)
        Mod.exists?(@user1mod.id).should be_true
      end
    end
  end

end
