class ModsController < ApplicationController

  assign_records_for User, Mod
  before_filter :assign_records

  before_filter :ensure_user!, :except => [:index, :new, :create]
  before_filter :ensure_mod!,  :except => [:index, :new, :create]

  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :authorize_change!,  :except => [:index, :show]

  def index
    page_title "Modules"

    if @user_found
      # NOTE: The user's page has a module listing, use that instead.
      return redirect_to [@user]
    elsif @user_found == false
      return ensure_user!
    end

    @cache_key_for_mods_list = "mods-index".tap do |k|
      k << "-user_#{@user.id}" if @user
    end
    
    respond_to do |format|
      format.html do
        mods = search_scope
        @mods = Defer { mods.paginate :page => params[:page] }
        @mods_count = Defer { mods.count }
      end
      format.json do
        @mods = search_scope
        render :json => json_for_mods(@mods)
      end
    end
  end

  def new
    page_title "Add a module"
    @mod = Mod.new
  end

  def create
    page_title "Add a module"
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
    page_title "Module: #{@mod.full_name}"
    releases = @mod.releases.ordered
    @releases = Defer { releases.paginate :page => params[:page], :order => 'version desc' }
    @releases_count = Defer { releases.count }
    @release = Defer { releases.first }
    respond_to do |format|
      format.html
      format.json { render :json => json_for_mods(@mod) }
    end
  end

  def edit
    page_title "Edit module: #{@mod.full_name}"
  end

  def update
    page_title "Edit module: #{@mod.full_name}"
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

    base = base.with_current_release.ordered

    return \
      params[:q] ?
      base.matching(params[:q]) :
      base
  end

  #===[ Helpers ]=========================================================

  # Is the current user allowed to change this record?
  def can_change?
    if @mod_found == true
      return(@mod.can_be_changed_by? current_user)
    elsif @user_found == true
      return(@user.can_be_changed_by? current_user)
    else
      return(current_user.present?)
    end
  end
  helper_method :can_change?

  #===[ Filters ]=========================================================

  # Only allow owner to change this record, else redirect with an error.
  def authorize_change!
    unless can_change?
      respond_with_forbidden("You must be the owner of this module to change it")
    end
  end

end
