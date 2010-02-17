class TagsController < ApplicationController

  before_filter :find_tag
  
  def show
    @category = Categories[@tag]
    @mods = Mod.tagged_with(@tag).paginate :page => params[:page], :order => 'mods.name DESC'
  end

  private

  def find_tag
    @tag = Tag.find_by_name(params[:id])
    unless @tag
      notify_of :error, "No such tag: #{params[:id]}"
      redirect_to root_path
    end
  end

end
