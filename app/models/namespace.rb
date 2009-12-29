class Namespace < ActiveRecord::Base
  include TitleDefaulting
  
  belongs_to :owner, :polymorphic => true

  DEFAULT_NAME = 'default'

  validates_presence_of :owner_id, :owner_type
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]

  def full_name
    @full_name ||= [owner.name, name].join('-')
  end

  def default?
    name == DEFAULT_NAME
  end

end
