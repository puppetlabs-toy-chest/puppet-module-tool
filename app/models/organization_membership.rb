class OrganizationMembership < ActiveRecord::Base

  belongs_to :user
  belongs_to :organization

  validates_presence_of :user_id
  validates_presence_of :organization_id

  bitmask :roles, :as => [:admin]
  
end
