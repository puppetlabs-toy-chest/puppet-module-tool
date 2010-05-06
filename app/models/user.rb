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

  devise :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  validates_format_of :username, :with => /^[[:alnum:]]{3,}$/, :message => "should be 3 or more alphanumeric characters"
  validates_uniqueness_of :username

  has_many :mods, :as => :owner

  # TODO Implement Watches
=begin
  has_many :watches
  has_many :watched_mods, :through => :watches, :source => :mod do
    def timeline
      TimelineEvent.for_mods(*self)
    end
  end

  def watching?(mod)
    watched_mods.include?(mod)
  end
=end

  def to_param
    username
  end
  
end
