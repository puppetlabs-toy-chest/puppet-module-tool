class ReleasesController < ApplicationController

  assign_records_for User, Mod, Release
  before_filter :assign_records

  before_filter :ensure_user!,    :except => [:index, :find]
  before_filter :ensure_mod!,     :except => [:index, :find]
  before_filter :ensure_release!, :except => [:new, :create, :find]

  before_filter :authenticate_user!, :except => [:index, :show, :find]
  before_filter :authorize_change!,  :except => [:index, :show, :find]
  
  def new
    @release = @mod.releases.new
  end

  def find
    @query = ReleaseQuery.new(@mod, params[:version])
    @release = @query.execute
    respond_to do |format|
      format.json do
        if @release
          render :json => {:version => @release.version, :file => @release.file.url, :version => @release.version}.to_json
        else
          render :status => 404
        end
      end
    end
  end

  def create
    @release = @mod.releases.new(params[:release])
    if @release.save
      notify_of "Released #{@release.version}"
      respond_to do |format|
        format.html do
          redirect_to user_mod_release_path(@user, @mod, @release)
        end
        format.json do
          render :json => @release.to_json
        end
      end
    else
      respond_to do |format|
        format.html do
          notify_of :error, "Could not save release"
          render :action => 'new'
        end
        format.json do
          render :json => {:error => @release.errors.full_messages.to_sentence}.to_json, :status => 500
        end
      end
    end
  end

  def show
  end

  def destroy
    @release.destroy
    respond_to do |format|
      format.html do
        notify_of "Removed release."
        redirect_to module_path(@release.mod.owner, @release.mod)
      end
      format.json do
        render :json => @release.to_json
      end
    end
  end

  private

  #===[ Helpers ]=========================================================

  # Is the current user allowed to change this record?
  def can_change?
    if @release_found.nil?
      return(@mod && current_user && @mod.owner == current_user)
    else
      return(@release && current_user && @release.owner == current_user)
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
