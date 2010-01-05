class ModsController < ApplicationController

  def index
    @mods = Mod.for_address(params[:q])
    respond_to do |format|
      format.json { render :json => serialize(@mods) }
    end
  end
  
  private

  # Serialize one or more modules to JSON
  def serialize(obj)
    obj.to_json(
                :only => [:name, :source],
                :methods => [:full_name]
                )
  end
  
end
