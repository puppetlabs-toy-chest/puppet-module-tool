class Organization < ActiveRecord::Base

  has_many :owned_namespaces, :as => :owner, :class_name => 'Namespace'
  
  has_many :organization_memberships
  has_many :users, :through => :organization_memberships
end
