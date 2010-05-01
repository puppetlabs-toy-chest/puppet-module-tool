# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Include all helpers, all the time
  helper :all

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  # Filters
  before_filter :http_authenticate
  before_filter :set_mailer_host

  private

  #===[ Utilities ]=======================================================

  def notify_of(*args)
    message = args.pop
    type = args.shift || :notice
    flash[type] = message
  end
  alias_method :notify, :notify_of

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

  def http_authenticate
    authenticate_with_http_basic do |email, password|
      @user = User.authenticate(:email => email, :password => password)
    end
    sign_in @user if @user
    warden.custom_failure! if performed?
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host
  end

end
