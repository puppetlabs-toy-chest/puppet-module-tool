class UsersController < ApplicationController

  assign_records_for User
  before_filter :assign_records

  before_filter :ensure_user!, :except => [:index, :new, :create]
  before_filter :authenticate_user!, :except => [:index, :new, :create, :show, :switch]
  before_filter :authorize_change!,  :except => [:index, :new, :create, :show, :switch]

  def index
    @users = Defer { User.ordered }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      if User.confirmable?
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
    @mods = Defer { @user.mods.ordered.paginate(:page => params[:page]) }
    @cache_key_for_mods_list = "users-show_#{@user.id}"
  end

  def edit
  end

  def update
    if admin? && params[:user]
      @user.admin = params[:user][:admin]
    end
    if params[:user] && params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.update_attributes(params[:user])
      flash[:success] = 'Updated successfully'
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t('flash.users.destroy.notice', :default => 'User was removed')
    if current_user == @user
      sign_out current_user
      redirect_to root_path
    else
      redirect_to users_path
    end
  end

  def switch
    msg = "UsersController#switch: "
    if privileged?
      if current_user
        sign_out current_user
        msg << "User ##{current_user.id} #{current_user.username.inspect} logged out, "
      end
      reset_session
      sign_in @user
      msg << "User ##{@user.id} #{@user.username.inspect} logged in"
      Rails.logger.warn(msg)
      redirect_to @user
    else
      msg << "forbidden to " + (current_user ? "User ##{current_user.id} #{current_user.username}" : "anonymous")
      Rails.logger.warn(msg)
      notify_of :error, "You aren't allowed to switch to another user!"
      redirect_back_or_to(root_path)
    end
  end

  protected

  #===[ Helpers ]=========================================================

  # Is the current user allowed to change this record?
  def can_change?
    if @user_found == true
      return(@user.can_be_changed_by? current_user)
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
