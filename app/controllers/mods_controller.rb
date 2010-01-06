class ModsController < ApplicationController

  def index
    @mods = params[:q] ? Mod.for_address(params[:q]) : []
    respond_to do |format|
      format.json { render :json => serialize(@mods) }
      format.html
    end
  end

  def show
    @mod = Mod.first(:conditions => {:address => params[:id]})
    if @mod
      respond_to do |format|
        format.json { render :json => serialize(@mod) }
        format.html
      end
    else
      render :status => 404
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
