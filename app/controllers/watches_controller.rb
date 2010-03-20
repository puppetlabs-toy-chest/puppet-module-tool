class WatchesController < ApplicationController

  before_filter :find_mod
  before_filter :authenticate_user!, :only => [:create]

  def create
    current_user.watches.create(:mod_id => @mod.id)
    respond_to do |format|
      format.html do
        redirect_to module_path(@mod.owner, @mod)
      end
      format.js
    end
  end

  def destroy
    @watch = current_user.watches.find(params[:id])
    @watch.destroy
    respond_to do |format|
      format.html do
        redirect_to module_path(@mod.owner, @mod)
      end
      format.js
    end
  end

  private

  def find_mod
    @mod = Mod.find(params[:mod_id])
  end

end



