class TagsController < ApplicationController

  assign_records_for Tag
  before_filter :assign_records

  def show
    @tag_name = params[:id]
    if @tag
      @category = Categories[@tag]
      @mods = Mod.tagged_with(@tag).ordered.paginate :page => params[:page]
    else
      @category = nil
      @mods = []

      respond_with_not_found("No modules tagged with #{@tag_name.inspect} found")
    end
  end
end
