class Organization < ActiveRecord::Base

  has_many :namespaces, :as => :owner
  
  has_many :organization_memberships
  has_many :users, :through => :organization_memberships
  
end
