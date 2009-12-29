module TitleDefaulting

  def self.included(base)
    base.instance_eval do
      include Instance
      before_save :default_title!
      alias_method :default_title!, :current_title
    end
  end

  module Instance

    def title
      @title ||= current_title
    end
    
    private

    def current_title
      title = read_attribute(:title)
      if title.blank?
        write_attribute(:title, default_title)
      else
        title
      end
    end
    
    def default_title
      name.to_s.titleize
    end

  end
  
end
