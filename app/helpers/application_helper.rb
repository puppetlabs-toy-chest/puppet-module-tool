# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def category_list
    haml_tag :div, :class => 'section' do
      haml_concat link_to('Add a module', new_mod_path, :class => 'section-link')
      haml_tag :h3, "Modules"
      haml_tag :ul, :class => 'local-navigation' do
        haml_tag :li, :class => (controller.controller_name == 'mods' && action_name == 'index' ? 'important active' : 'important inactive')  do
          haml_concat link_to("All Modules", mods_path)
        end
        Categories.each do |title, tag|
          haml_tag :li, :class => (@tag && @tag.name == tag.to_s) ? :active : :inactive do
            haml_concat link_to(title, "/tags/#{tag}")
          end
        end
      end
    end
  end

  def count(name, collection)
    method = collection.respond_to?(:count) ? :count : :size
    count = collection.send(method)
    if count == 0
      content_tag :p, "No #{name.pluralize} found.", :class => 'blank'
    else
      content_tag :p, "#{pluralize count, name} found."
    end
  end

  def tag_list(taggable)
    tags = taggable.tags.map do |tag|
      name = Categories[tag] || tag
      link_to name, tag, :title => %(Tagged "#{tag.name}")
    end
    tags.join(', ')
  end
  
end
