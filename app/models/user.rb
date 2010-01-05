class User < ActiveRecord::Base
  include BCrypt

  has_many :namespace_memberships
  has_many :namespaces, :through => :namespace_memberships

  has_many :owned_namespaces, :as => :owner, :class_name => 'Namespace'
  
  has_many :organization_memberships
  has_many :organizations, :through => :organization_memberships
  
  validates_format_of :username, :with => /^[[:alnum:]]{3,}$/, :message => "should be 3 or more alphanumeric characters"
  validates_uniqueness_of :username

  def self.authenticate(username_or_email, password)
    user = first(:conditions => ["username = :q or email = :q", {:q => username_or_email}])
    user if user && user.password == password
  end

  def name
    username
  end

  def password
    @password ||= Password.new(read_attribute(:password))
  end

  def password=(new_password)
    @password = Password.create(new_password)
    write_attribute(:password, @password)
  end

  def to_param
    name
  end

end
