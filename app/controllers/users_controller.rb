class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :update, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      if @user.respond_to?(:confirm!)
        flash[:success] = t('devise.confirmations.send_instructions')
        sign_in @user if @user.class.confirm_within > 0
      else
        flash[:success] = t('flash.users.create.notice', :default => 'User was successfully created.')
      end

      # Redirect to stored location for user in session or to the home page.
      redirect_to stored_location_for(:user) || root_url
    else
      render :new
    end
  end

  def show
    @user = User.find_by_username(params[:id])
    @mods = @user.mods.paginate(:page => params[:page], :order => 'name desc')
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:success] = 'Updated successfully'
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    current_user.destroy
    sign_out current_user
    flash[:success] = t('flash.users.destroy.notice', :default => 'User was removed')
    redirect_to root_path
  end
  
end
