class ReleasesController < ApplicationController

  before_filter :find_mod
  before_filter :find_release, :only => [:show, :destroy]
  before_filter :authenticate_user!, :only => [:create, :update, :destroy]
  before_filter :restrict_user!, :only => [:create, :update, :destroy]
  
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
      @release.extract_metadata!
      notify_of "Released #{@release.version}"
      respond_to do |format|
        format.json do
          render :json => @release.to_json
        end
        format.html do
          redirect_to module_path(@user, @mod)
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
      format.json do
        render :json => @release.to_json
      end
      format.html do
        notify_of "Removed release."
        redirect_to module_path(@release.mod.user, @release.mod)
      end
    end
  end

  private

  def find_mod
    @user = User.find_by_username(params[:user_id])
    @mod = @user.mods.find_by_name(params[:mod_id])
  end

  def find_release
    @release = @mod.releases.find_by_version(params[:id])
    unless @release
      respond_to do |format|
        format.json do
          render :json => {:error => "No such release version"}.to_json, :status => 404
        end
        format.html do
          render :status => 404
        end
      end
    end
  end

  def restrict_user!
    unless @user == current_user
      respond_to do |format|
        format.json do
          render :status => 500, :json => {:error => "You do not have access to that module."}.to_json
        end
        format.html do
          notify_of :error, "You do not have access to that module."
          redirect_to module_path(@user, @mod)
        end
      end
    end
  end
  
end
