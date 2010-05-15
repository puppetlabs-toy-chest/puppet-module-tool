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

    it "should destroy a user" do
      sign_in @user
      delete :destroy, :id => @user.to_param

      response.should redirect_to(root_path)
      User.exists?(@user.id)
    end

    it "should demand that an anonymous user login" do
      delete :destroy, :id => @user.to_param

      response_should_redirect_to_login
    end

    it "should forbid a user from destroying another's profile" do
      other = Factory :user
      sign_in other
      delete :destroy, :id => @user.to_param

      response_should_be_forbidden
    end
  end
end