class WatchesController < ApplicationController

  before_filter :find_mod
  before_filter :authenticate_user!, :only => [:create]

  def create
    current_user.watches.create(:mod_id => @mod.id)
    redirect_to module_path(@mod.owner, @mod)
  end

  private

  def find_mod
    @mod = Mod.find(params[:mod_id])
  end

end



