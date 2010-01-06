class User < ActiveRecord::Base

  devise :all

  has_many :namespace_memberships
  has_many :namespaces, :through => :namespace_memberships

  has_many :owned_namespaces, :as => :owner, :class_name => 'Namespace'
  
  has_many :organization_memberships
  has_many :organizations, :through => :organization_memberships
  
  validates_format_of :username, :with => /^[[:alnum:]]{3,}$/, :message => "should be 3 or more alphanumeric characters"
  validates_uniqueness_of :username

  def name
    username
  end

  def to_param
    username
  end

end
