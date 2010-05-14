# == Schema Information
# Schema version: 20100320030102
#
# Table name: users
#
#  id                   :integer         not null, primary key
#  username             :string(255)
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  confirmation_token   :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer         default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  display_name         :string(255)
#

class User < ActiveRecord::Base
  
  # Protection
  attr_accessible :username, :email, :display_name, :password, :password_confirmation, :remember_me

  # Configure the Devise authentication system:
  devise :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:username]

  # Validations
  validates_format_of :username, :with => /\A[[:alnum:]]{3,}\z/, :message => "should be 3 or more alphanumeric characters"
  validates_uniqueness_of :username

  # Associations
  has_many :mods, :as => :owner, :dependent => :destroy

  # Scopes
  named_scope :ordered, :order => 'lower(username) asc'
  named_scope :admins, :conditions => {:admin => true}
  named_scope :nonadmins, :conditions => {:admin => false}

  # TODO Implement Watches
=begin
  has_many :watches, :dependent => :destroy
  has_many :watched_mods, :through => :watches, :source => :mod, :dependent => :destroy do
    def timeline
      TimelineEvent.for_mods(*self)
    end
  end

  def watching?(mod)
    watched_mods.include?(mod)
  end
=end

  # Return unique human-readable string key for this record.
  def to_param
    return self.username
  end

  # Can this +user+ change this record?
  def can_be_changed_by?(user)
    return user && (user.admin? || user == self)
  end

end
