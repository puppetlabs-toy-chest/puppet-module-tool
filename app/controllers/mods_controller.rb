class ModsController < ApplicationController

  before_filter :assign_user, :only => :index
  before_filter :assign_user_or_redirect, :except => [:index, :new, :create]
  before_filter :assign_mod_or_redirect, :except => [:index, :new, :create]
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :authorize_change_or_redirect, :except => [:index, :show, :new, :create]

  def index
    if @user_assigned_status == false
      notify_of :error, "Could not find user '#{params[:user_id]}'"
    end
    @mods = search_scope
    respond_to do |format|
      format.json do
        render :json => json_for(@mods)
      end
      format.html do
        @mods = @mods.paginate :page => params[:page], :order => 'name DESC'
      end
    end
  end

  def new
    @mod = Mod.new
  end

  def create
    @mod = current_user.mods.new(params[:mod])
    if @mod.save
      notify_of "Module added"
      redirect_to module_path(current_user, @mod)
    else
      notify_of :error, "Could not save module"
      render :action => 'new'
    end
  end

  def show
    @releases = @mod.releases.ordered.paginate :page => params[:page], :order => 'version desc'
    @release = @releases.first
    respond_to do |format|
      format.json { render :json => json_for(@mod) }
      format.html
    end
  end

  def edit
  end

  def update
    if @mod.update_attributes(params[:mod])
      notify_of "Updated module"
      redirect_to module_path(@mod.owner, @mod)
    else
      notify_of :error, "Could not update module"
      render :action => 'edit'
    end
  end

  def destroy
    @mod.destroy
    notify_of "Destroyed module"
    redirect_to vanity_path(@mod.owner)
  end

  private

  #===[ Utilities ]=======================================================

  # Return records for all users, a single user, or a search query on either.
  def search_scope
    base = \
      @user ?
      @user.mods :
      Mod

    return \
      params[:q] ?
      base.with_releases.matching(params[:q]) :
      base.with_releases
  end

  # Serialize one or more mods to JSON.
  def json_for(obj)
    obj.to_json(
      :only => [:name, :project_url],
      :methods => [:full_name, :version]
    )
  end

  #===[ Helpers ]=========================================================

  # Is the current user allowed to change this record?
  def can_change?
    return(@mod && current_user && @mod.owner == current_user)
  end
  helper_method :can_change?

  #===[ Filters ]=========================================================

  # Assign a @user record and @user_assigned_status.
  #
  # The @user_assigned_status values are:
  # * true => User was specified by request and found.
  # * false => User was specified by request but not found.
  # * nil => User was not specified by request and is thus not set.
  def assign_user
    if params[:user_id]
      @user = User.find_by_username(params[:user_id])
      @user_assigned_status = @user.present?
    else
      @user = nil
      @user_assigned_status = nil
    end
  end

  # Assign a @user record or redirect with an error.
  def assign_user_or_redirect
    assign_user if @user_assigned_status.nil?
    unless @user
      notify_of :error, "Could not find user '#{params[:user_id]}'"
      redirect_back_or_to mods_path
    end
  end

  # Assign a @mod record or redirect with an error.
  def assign_mod_or_redirect
    unless @mod = @user.mods.find_by_name(params[:id])
      notify_of :error, "Could not find module '#{params[:id]}'"
      redirect_back_or_to vanity_path(@user)
    end
  end

  # Only allow owner to change this record, else redirect with an error.
  def authorize_change_or_redirect
    unless can_change?
      notify_of :error, "Access denied, you must be the owner of this module to change it"
      redirect_back_or_to module_path(@mod.owner, @mod)
    end
  end

end
