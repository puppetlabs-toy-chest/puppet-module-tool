class ModsController < ApplicationController

  def show
    @mod = Mod.find(params[:id])
    respond_to do |format|
      format.json do
        redirect_to @mod.source
      end
    end
  end
  
end
