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

  validates_presence_of :address
  validates_uniqueness_of :address
  validates_format_of :address, :with => /^[[:alnum:]]+-[[:alnum:]]+$/
  before_validation :set_address!
  attr_protected :address

  def default?
    name == DEFAULT_NAME
  end

  def allows?(user)
    users.first(:conditions => {:id => user.id}) ? true : false
  end

  def to_param
    address
  end

  def address
    @address ||= read_attribute(:address) || set_address!
  end

  def set_address!
    if owner
      write_attribute(:address, [owner.name, name].join('-'))
    end
  end

end
