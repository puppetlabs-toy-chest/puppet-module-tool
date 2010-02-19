class ReleasesController < ApplicationController

  before_filter :find_mod
  before_filter :find_release, :only => [:show]
  
  def new
    @release = @mod.releases.new
  end

  def find
    # TODO: Extract this to a query helper object
    if params[:version]
      version, matcher = params[:version].split(' ').reverse
      matcher ||= '=='
      @release = @mod.releases.ordered.detect do |release|
        release_version = Versionomy.parse(release.version)
        release_version.send(matcher, version)
      end
    else
      @release = @mod.releases.first
    end
    respond_to do |format|
      format.json do
        if @release
          render :json => {:version => @release.version, :file => @release.file.url}.to_json
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
        format.json do
          render :json => @release.to_json
        end
        format.html do
          redirect_to module_path(@user, @mod)
        end
      end
    else
      notify_of :error, "Could not save release"
      render :action => 'new'
    end
  end

  def show
  end

  private

  def find_mod
    @user = User.find_by_username(params[:user_id])
    @mod = @user.mods.find_by_name(params[:mod_id])
  end

  def find_release
    @release = @mod.releases.find_by_version(params[:id])
  end
  
end
