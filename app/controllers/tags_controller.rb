class TagsController < ApplicationController

  assign_records_for Tag
  before_filter :assign_records

  before_filter :ensure_tag!, :only => [:show]

  def show
    @category = Categories[@tag]
    @mods = Mod.tagged_with(@tag).paginate :page => params[:page], :order => 'mods.name DESC'
  end
end
