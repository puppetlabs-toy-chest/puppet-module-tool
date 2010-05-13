require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do

  describe "index" do
    it "should display list of users" do
      user1 = Factory :user
      user2 = Factory :user

      get :index

      response.should be_success
      assigns[:users].should be_a_kind_of(Array)
      assigns[:users].size.should == 2
      assigns[:users].should include(user1)
      assigns[:users].should include(user2)
    end
  end

  describe "new" do
    it "should display new user form" do
      get :new

      response.should be_success
      assigns[:user].should be_a_new_record
    end
  end

  describe "create" do
    it "should create a user when given valid arguments" do
      attributes = Factory.attributes_for :user
      post :create, :user => attributes

      user = assigns[:user]
      user.should_not be_a_new_record
      response.should redirect_to(user_path(user))
    end

    it "should fail when given invalid arguments" do
      attributes = Factory.attributes_for :user
      attributes[:username] = '$!%#'
      post :create, :user => attributes

      user = assigns[:user]
      user.should be_a_new_record
      response.should be_success
    end
  end  
  
  describe "show" do
    it "should display a user" do
      user = Factory :user
      get :show, :id => user.to_param

      assigns[:user].should == user
      response.should be_success
    end
    
    it "should fail when given an invalid user" do
      get :show, :id => "invalid user"

      response_should_be_not_found
    end
  end
  
  describe "edit" do
    before do
      @user = Factory :user
    end

    it "should show an edit form" do
      sign_in @user
      get :edit, :id => @user.to_param

      response.should be_success
      assigns[:user].should == @user
    end

    it "should show an edit form for admin" do
      admin = Factory :admin
      sign_in admin
      get :edit, :id => @user.to_param

      response.should be_success
      assigns[:user].should == @user
    end

    it "should demand that an anonymous user login" do
      get :edit, :id => @user.to_param

      response_should_redirect_to_login
    end

    it "should forbid a user from editing another's profile" do
      other = Factory :user
      sign_in other
      get :edit, :id => @user.to_param

      response_should_be_forbidden
    end
  end
  
  describe "update" do
    before :each do
      @user = Factory :user

      @attributes = @user.attributes.symbolize_keys

      @valid_change = @attributes.clone
      @valid_change[:display_name] = 'Updated Username'

      @invalid_change = @attributes.clone
      @invalid_change[:username] = '$!%#'
    end

    it "should update a user" do
      sign_in @user
      put :update, :id => @user.to_param, :user => @valid_change

      assigns[:user].should == @user
      assigns[:user].display_name.should == @valid_change[:display_name]
      response.should redirect_to(user_path(@user))
    end

    it "should fail when given invalid attributes" do
      sign_in @user
      put :update, :id => @user.to_param, :user => @invalid_change

      assigns[:user].should == @user
      assigns[:user].username.should == @invalid_change[:username]
      response.should be_success
    end

    it "should demand that an anonymous user login" do
      put :update, :id => @user.to_param, :user => @valid_change

      response_should_redirect_to_login
    end
    
    it "should forbid a user from updating another's profile" do
      other = Factory :user
      sign_in other
      put :update, :id => @user.to_param, :user => @valid_change

      response_should_be_forbidden
    end

    it "should redirect if given an invalid user" do
      sign_in @user
      put :update, :id => "Invalid Username", :user => @valid_change

      response_should_be_not_found
    end
  end
  
  describe "destroy" do
    before :each do
      @user = Factory :user
    end

    it "should allow a user to destroy themselves" do
      sign_in @user
      delete :destroy, :id => @user.to_param

      response.should redirect_to(root_path)
      User.exists?(@user.id).should be_false
    end

    it "should allow an admin to destroy another user" do
      admin = Factory :admin
      sign_in admin
      delete :destroy, :id => @user.to_param

      response.should redirect_to(users_path)
      User.exists?(@user.id).should be_false
    end

    it "should demand that an anonymous user login" do
      delete :destroy, :id => @user.to_param

      response_should_redirect_to_login
      User.exists?(@user.id).should be_true
    end

    it "should forbid a user from destroying another's profile" do
      other = Factory :user
      sign_in other
      delete :destroy, :id => @user.to_param

      response_should_be_forbidden
      User.exists?(@user.id).should be_true
    end
  end

  describe "switch user" do
    before do
      @user = Factory :user
      @user2 = Factory :user
      @admin = Factory :admin
    end

    describe "when in dev mode" do
      before do
        Rails.stub!(:env => 'development')
      end

      it "should allow anonymous user" do
        should_not_be_logged_in
        post :switch, :id => @user.to_param

        should_be_logged_in_as @user
      end

      it "should allow logged in user" do
        sign_in @user2
        should_be_logged_in_as @user2
        post :switch, :id => @user.to_param

        should_be_logged_in_as @user
      end

      it "should allow admin user" do
        sign_in @admin
        should_be_logged_in_as @admin
        post :switch, :id => @user.to_param

        should_be_logged_in_as @user
      end
    end

    describe "when in 'production' environment" do
      before do
        Rails.stub!(:env => 'production')
      end

      it "should not allow anonymous user" do
        should_not_be_logged_in
        post :switch, :id => @user.to_param

        should_not_be_logged_in
        flash[:error].should_not be_blank
      end

      it "should not allow logged in user" do
        sign_in @user2
        should_be_logged_in_as @user2
        post :switch, :id => @user.to_param

        should_be_logged_in_as @user2
        flash[:error].should_not be_blank
      end

      it "should allow admin user" do
        sign_in @admin
        should_be_logged_in_as @admin
        post :switch, :id => @user.to_param

        should_be_logged_in_as @user
      end
    end
  end

  describe "utilities" do
    describe "can_change?" do
      it "should be true if user is found and record allows it" do
        user = Factory :user
        controller.instance_variable_set(:@user_found, true)
        controller.instance_variable_set(:@user, user)
        controller.stub!(:current_user => user)
        controller.send(:can_change?).should be_true
      end

      it "should not be true if user is found but record doesn't allows it" do
        user1 = Factory :user
        user2 = Factory :user
        controller.instance_variable_set(:@user_found, true)
        controller.instance_variable_set(:@user, user1)
        controller.stub!(:current_user => user2)
        controller.send(:can_change?).should_not be_true
      end

      it "should not be true if user wasn't found" do
        user = Factory :user
        controller.instance_variable_set(:@user_found, false)
        controller.stub!(:current_user => nil)
        controller.send(:can_change?).should_not be_true
      end
    end
  end
end
