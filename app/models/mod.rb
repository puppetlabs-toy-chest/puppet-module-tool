class Mod < ActiveRecord::Base
  include TitleDefaulting
  delegate :allows?, :to => :namespace

  belongs_to :namespace
  validates_presence_of :namespace_id
  
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => :namespace_id

  def full_name
    @full_name ||= [namespace.full_name, name].join('-')
  end

  def repo_path
    @repo_path ||= full_name.tr('-', '/')
  end
  
end
