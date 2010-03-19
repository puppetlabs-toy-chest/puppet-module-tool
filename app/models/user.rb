class User < ActiveRecord::Base

  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  validates_format_of :username, :with => /^[[:alnum:]]{3,}$/, :message => "should be 3 or more alphanumeric characters"
  validates_uniqueness_of :username

  has_many :mods, :as => :owner
  has_many :watches
  has_many :watched_mods, :through => :watches, :source => :mod

  def name
    username
  end

  def to_param
    username
  end

end
