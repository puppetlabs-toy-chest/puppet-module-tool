# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  filter_parameter_logging :password # Scrub sensitive parameters from
  # your log
  before_filter :http_authenticate
  before_filter :set_mailer_host

  private
  
  def notify_of(*args)
    message = args.pop
    type = args.shift || :notice
    flash[type] = message
  end
  alias_method :notify, :notify_of

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

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      user_timeline_events_path(resource)
    else
      super
    end
  end
  
end
