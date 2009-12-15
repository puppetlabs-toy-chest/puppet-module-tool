class Namespace < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  DEFAULT_NAME = 'default'

  validates_presence_of :owner_id, :owner_type
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]

  before_save :default_title!

  def title
    @title ||= current_title
  end

  def full_name
    @full_name ||= [owner.name, name].join('-')
  end

  def default?
    name == DEFAULT_NAME
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

  ##
  # Call <tt>title</tt> to write default, if necessary
  alias_method :default_title!, :current_title

end
