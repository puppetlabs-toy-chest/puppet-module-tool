# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Include all helpers, all the time
  helper :all

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  # Filters
  before_filter :http_authenticate
  before_filter :set_mailer_default_url_options

  private

  #===[ Utilities ]=======================================================

  # Notify the user with a cookie-based flash notification. 
  #
  # Examples:
  #
  #   # Message for default notification level:
  #   notify_of "Hello"
  #
  #   # Message for specific notifcation level:
  #   notify_of :error, "OH NOES!"
  def notify_of(level_or_message, message=nil)
    if message
      level = level_or_message
    else
      level = :notice
      message = level_or_message
    end
    flash[level] = message
  end
  alias_method :notify, :notify_of

  # Redirect user to this path after they sign in using Devise.
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      user_timeline_events_path(resource)
    else
      super
    end
  end

  # Redirect back to previous page user visited, else to +path+.
  def redirect_back_or_to(path)
    begin
      redirect_to :back
    rescue ActionController::RedirectBackError => e
      redirect_to path
    end
  end

  #===[ Filters ]=========================================================

  # Sign-in a user using HTTP Basic authentication.
  def http_authenticate
    authenticate_with_http_basic do |email, password|
      @user = User.authenticate(:email => email, :password => password)
    end
    sign_in @user if @user
    warden.custom_failure! if performed?
  end

  # Set the default URL options for the mailer, so that emails it generates have proper
  def set_mailer_default_url_options
    ActionMailer::Base.default_url_options[:host] = request.host
    ActionMailer::Base.default_url_options[:port] = request.port unless request.port == 80
    ActionMailer::Base.default_url_options[:protocol] = /(.*):\/\//.match(request.protocol)[1] if request.protocol.ends_with?("://") && request.protocol != 'http'
  end

end
