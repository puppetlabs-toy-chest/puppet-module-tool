class User < ActiveRecord::Base
  include BCrypt

  def self.authenticate(username_or_email, password)
    user = first(:conditions => ["username = :q or email = :q", {:q => username_or_email}])
    user if user && user.password == password
  end

  def password
    @password ||= Password.new(read_attribute(:password))
  end

  def password=(new_password)
    @password = Password.create(new_password)
    write_attribute(:password, @password)
  end

end
