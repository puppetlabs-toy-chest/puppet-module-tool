class ModsController < ApplicationController

  assign_records_for User, Mod
  before_filter :assign_records

  before_filter :ensure_user!, :except => [:index, :new, :create]
  before_filter :ensure_mod!,  :except => [:index, :new, :create]

  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :authorize_change_or_redirect, :except => [:index, :show, :new, :create]

  def index
    if @user_found == false
      return ensure_user!
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

  # Only allow owner to change this record, else redirect with an error.
  def authorize_change_or_redirect
    unless can_change?
      notify_of :error, "Access denied, you must be the owner of this module to change it"
      redirect_back_or_to module_path(@mod.owner, @mod)
    end
  end

end
