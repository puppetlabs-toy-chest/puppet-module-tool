class UsersController < ApplicationController

  assign_records_for User
  before_filter :assign_records

  before_filter :ensure_user!, :except => [:index, :new, :create]
  before_filter :authenticate_user!, :except => [:index, :new, :create, :show]
  before_filter :authorize_change!,  :except => [:index, :new, :create, :show]

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
      redirect_to stored_location_for(:user) || @user
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
      redirect_to @user
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

  protected

  #===[ Helpers ]=========================================================

  # Is the current user allowed to change this record?
  def can_change?
    if @user_found == true
      return(@user && current_user && @user == current_user)
    else
      # NOTE: This should never happen because routing should prevent access to
      # this resource without a username, and #assign_records will prevent
      # loading of user records that don't exist.
      return false
    end
  end
  helper_method :can_change?

  #===[ Filters ]=========================================================

  # Only allow owner to change this record, else redirect with an error.
  def authorize_change!
    unless can_change?
      respond_with_forbidden("You must be be this user to change the profile.")
    end
  end

end
