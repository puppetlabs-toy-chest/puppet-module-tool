class ModsController < ApplicationController

  before_filter :find_user
  before_filter :find_mod, :only => [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy]
  
  def index
    @mods = search_scope
    respond_to do |format|
      format.json { render :json => serialize(@mods) }
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
      format.json { render :json => serialize(@mod) }
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
  
  private
  
  def search_scope
    if params[:q]
      Mod.with_releases.matching(params[:q])
    else
      Mod.with_releases
    end
  end

  # Serialize one or more modules to JSON
  def serialize(obj)
    obj.to_json(
                :only => [:name, :source],
                :methods => [:full_name, :version]
                )
  end

  def find_user
    if params[:user_id]
      @user = User.find_by_username(params[:user_id])
    end
  end

  def find_mod
    @mod = @user.mods.find_by_name(params[:id])
  end
  
end
