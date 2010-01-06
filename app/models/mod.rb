class Mod < ActiveRecord::Base
  include TitleDefaulting
  delegate :allows?, :to => :namespace

  belongs_to :namespace
  validates_presence_of :namespace_id
  
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => :namespace_id

  validates_format_of :source, :with => /^(git|https?):\/\//, :message => "location invalid (must start with http://, https://, or git://)"

  validates_presence_of :address
  validates_uniqueness_of :address
  validates_format_of :address, :with => /^[[:alnum:]]+-[[:alnum:]]+-[[:alnum:]]+$/
  before_validation :set_address!
  attr_protected :address

  named_scope :for_address, proc { |a|
    lookup = ModuleLookup.new(a)
    {:conditions => ['mods.address like ?', lookup.to_sql]}
  }
  
  def to_param
    address
  end

  def address
    @address ||= read_attribute(:address) || set_address!
  end

  def set_address!
    if namespace
      write_attribute(:address, [namespace.address, name].join('-'))
    end
  end
  
end
