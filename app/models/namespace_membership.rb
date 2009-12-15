class NamespaceMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :namespace

  validates_presence_of :user_id
  validates_presence_of :namespace_id

  bitmask :roles, :as => [:admin]
  
end
