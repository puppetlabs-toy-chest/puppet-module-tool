# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password # Scrub sensitive parameters from your log

  def notify_of(*args)
    message = args.pop
    type = args.shift || :notice
    flash[type] = message
  end
  alias_method :notify, :notify_of

end
