# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  private

  def require_user
    unless authenticated?
      redirect_to new_session_path
    end
  end

  def require_no_user
    if authenticated?
      notify "Please sign-in."
      redirect_to
    end
  end

  def notify_of(*args)
    message = args.pop
    type = args.shift || :notice
    flash[type] = message
  end
  alias_method :notify, :notify_of

end
