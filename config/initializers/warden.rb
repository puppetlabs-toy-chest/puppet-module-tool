Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = SessionsController
end

# Declare your strategies here
Warden::Strategies.add(:password) do

  def valid?
    params[:username] || params[:password]
  end
  
  def authenticate!
    user = User.authenticate(params[:username], params[:password])
    success!(user) if user
  end
  
end
