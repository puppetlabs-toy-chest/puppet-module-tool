class Namespace < ActiveRecord::Base
  include TitleDefaulting
  
  DEFAULT_NAME = 'default'

  belongs_to :owner, :polymorphic => true
  
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_presence_of :owner_id
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]
  
  has_many :mods

  has_many :namespace_memberships
  has_many :users, :through => :namespace_memberships

  def full_name
    @full_name ||= [owner.name, name].join('-')
  end

  def default?
    name == DEFAULT_NAME
  end

  def allows?(user)
    users.first(:conditions => {:id => user.id}) ? true : false
  end

  def to_param
    name
  end

end
