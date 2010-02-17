# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def tab_to_unless_current (name, url)
    link_to_unless_current name, url do
      content_tag(:span, name, :class => "current")
    end
  end

  def inspector_table(collection, key=nil, value=nil, options={})
    key, options = nil, key if key.is_a?(Hash)
    unless collection.is_a?(Hash)
      key ||= :name; value ||= :description

      collection_hash_values = collection.map{ |c|
        [
         key.respond_to?(:call) ? key.call(c) : link_to_if(options[:link], c.send(key), c),
         value.respond_to?(:call) ? value.call(c) : c.send(value),
        ]
      }.flatten

      collection = Hash[*collection_hash_values]
    end

    key ||= :key; value ||= :value

    render :partial => 'shared/inspector', :object => collection, :locals => {:key => key.to_s, :value => value.to_s, :options => options}
  end

  def error_messages_for(object_name, options)
    objects = [options.delete(:object)].flatten
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }

    return '' if count.zero?

    header_message = "Please correct #{count > 1 ? "these #{count} errors" : 'this error'}:"
    error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, h(msg)) } }.join

    contents = content_tag(:h3, header_message) +
      content_tag(:ul, error_messages)

    content_tag(:div, contents, :class => 'errors element')
  end

  def category_list
    haml_tag :div, :class => 'section' do
      haml_tag :h3, "Categories"
      haml_tag :ul, :class => 'local-navigation' do
        Categories.each do |title, tag|
          haml_tag :li, :class => (@tag && @tag.name == tag.to_s) ? :active : :inactive do
            haml_concat link_to(title, "/tags/#{tag}")
          end
        end
      end
    end
  end

  def session_nav
    haml_tag :p, :id => 'session-navigation' do
      if current_user
        haml_concat link_to("Welcome, #{current_user.username}", vanity_path(current_user), :class => 'gateway')
        haml_concat link_to("Sign out", destroy_user_session_path, :class => 'gateway')
      else
        haml_concat link_to("Sign in", new_user_session_path, :class => 'gateway')
        haml_concat link_to("Register", new_user_path, :class => 'gateway')
      end
    end
  end

  def count(collection)
    method = collection.respond_to?(:count) ? :count : :size
    count = collection.send(method)
    if count == 0
      content_tag :p, "No modules found.", :class => 'blank'
    else
      content_tag :p, "#{pluralize count, 'module'} found."
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
