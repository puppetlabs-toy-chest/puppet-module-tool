class TagsController < ApplicationController

  assign_records_for Tag
  before_filter :assign_records

  def show
    @tag_name = params[:id]
    page_title "Tag: #{@tag_name}"
    if @tag
      @category = Defer { Categories[@tag] }
      mods = Defer { Mod.tagged_with(@tag).ordered }

      respond_to do |format|
        format.html do
          @mods = Defer { mods.paginate :page => params[:page] }
          @mods_count = Defer { mods.count }
        end
        format.json do
          @mods = mods
          render :json => json_for_mods(@mods)
        end
      end

      @cache_key_for_mods_list = "tags-show_#{@tag.id}"
    else
      @category = nil
      @mods = []

      respond_with_not_found("No modules tagged with #{@tag_name.inspect} found")
    end
  end
end
