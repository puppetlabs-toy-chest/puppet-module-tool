class ModsController < ApplicationController

  before_filter :check_lookup

  def index
    @mods = lookup.mods
    respond_to do |format|
      format.json { render :json => serialize(@mods) }
    end
  end
  
  def show
    @mod = lookup.mods.first(:conditions => {:name => params[:id]})
    respond_to do |format|
      format.json do
        render :json => serialize(@mod)
      end
    end
  end

  private

  # Build lookup, which uses the :id and :q params to narrow
  # down modules.  If using a hierarchal query (:q), redirect to
  # the nested route, otherwise fall through for querying (after
  # verifying the necessary information has been provided)
  def lookup
    return @lookup if defined?(@lookup)
    @lookup = ModuleLookup.new(params)
    if @lookup.hierarchal?
      redirect_to @lookup.to_path
    elsif !@lookup.ready?
      render :status => 500 
    end
  end
  alias_method :check_lookup, :lookup

  # Serialize one or more modules to JSON
  def serialize(obj)
    obj.to_json(
                :only => [:name, :source],
                :methods => [:full_name]
                )
  end
  
end
