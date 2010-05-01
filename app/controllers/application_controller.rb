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

  # An action that's only routed during test/development, used by tests.
  def test
    render :text => "TEST"
  end

  private

  #===[ Assigns ]=========================================================

  # Array of ActiveRecord classes to assign records to.
  class_inheritable_accessor :assign_records_by

  # Assign records from the request for the given +classes+.
  #
  # Example:
  #   class MyController < ApplicationController
  #     assign_records_for User, Mod, Release
  #     ...
  #   end
  def self.assign_records_for(*classes)
    self.assign_records_by = classes
  end

  # Assign records from the request, based on the classes set for a controller 
  # by ::assign_records_for.
  #
  # If `::assgin_records_for User`, this will assign:
  # * @user: A User record, if one was found.
  # * @user_key: The param value passed by the request that was used to find the
  #   record, e.g. if `param[:user_id]` was "myusername", this will be "myusername".
  # * @user_found: Boolean indicating if the record was searched for and found,
  #   if no search was performed, will be nil.
  def assign_records
    log = []
    tail = nil
    last = assign_records_by.size - 1
    self.assign_records_by.each_with_index do |type, i|
      base = type.name.tableize.singularize
      param_key = (i == last ? "id" : "#{base}_id").to_sym
      model_key = \
        if type == User
          :username
        elsif type == Mod
          :name
        elsif type == Release
          :version
        else
          raise ArgumentError, "Unknown type: #{type}"
        end
      tail = tail ? tail.send(type.name.tableize) : type
      # log << "Tail: #{tail}"
      log << "* Looking for #{type.name} using param key #{param_key.inspect} ..."
      if param_value = params[param_key]
        log << "- Found param value #{param_value.inspect}"
        self.instance_variable_set("@#{base}_key", param_value)
        if record = tail.find(:first, :conditions => {model_key => param_value})
          self.instance_variable_set("@#{base}", record)
          self.instance_variable_set("@#{base}_found", true)
          log << "- Found record #{type.name}##{record.id} and assigned to @#{base}"
          tail = record
        else
          self.instance_variable_set("@#{base}_found", false)
          log << "- No record not found"
          break
        end
      else
        log << "- No param value not found"
        break
      end
    end
  ensure
    Rails.logger.debug("** assign_records for #{request.path.inspect}:")
    for entry in log
      Rails.logger.debug("   #{entry}")
    end
  end

  # Ensure that a record of the given +type+ was assigned by #assign_records.
  def ensure_record!(type)
    name = type.name.tableize.singularize
    label = type == Mod ? "module" : name
    value = self.instance_variable_get("@#{name}_key")
    found = self.instance_variable_get("@#{name}_found")

    unless found
      message = "Could not find #{label}"
      message << " #{value.inspect}" if value.present?
      respond_with_not_found message
    end
  end

  # Ensure that a User record was assigned to this request.
  def ensure_user!
    ensure_record! User
  end

  # Ensure that a Mod record was assigned to this request.
  def ensure_mod!
    ensure_record! Mod
  end

  # Ensure that a Release record was assigned to this request.
  def ensure_release!
      ensure_record! Release
  end

  #===[ Utilities ]=======================================================

  # Render response for a resource that was not found. See #respond_with_error 
  # for documentation on the +message+ and +body+ arguments.
  def respond_with_not_found(message, body=nil)
    respond_with_error(:not_found, message, body)
  end

  # Render response for a resource that was forbidden. See #respond_with_error
  # for documentation on the +message+ and +body+ arguments.
  def respond_with_forbidden(message, body=nil)
    respond_with_error(:forbidden, message, body)
  end

  # Render response for an error.
  #
  # Arguments:
  # * status: An HTTP status symbol, e.g. :not_found. Required.
  # * message: A message string to display. Required.
  # * body: A body string to display if rendering an HTML page. Optional.
  #
  # Examples:
  #
  #   # Respond with a just a message:
  #   respond_with_error(:not_found, "Foo not found")
  #
  #   # Respond with a message and a body with link for the HTML page:
  #   respond_with_not_found(:not_found, "Foo not found, "Sad, isn't it?")
  def respond_with_error(status, message, body=nil)
    case status
    when :not_found, :forbidden
      status_string = CGI::HTTP_STATUS[status.to_s.upcase]
    else
      raise ArgumentError, "Unknown status: #{status}"
    end

    message = "#{status_string}: #{message}"
    respond_to do |format|
      format.html do
        @message = message
        @body = body
        render "errors/#{status}", :status => status
      end
      format.json { render :json => { :error => message }, :status => status }
      format.xml  { render :xml  => { :error => message }, :status => status }
    end
  end

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
      @user = User.authenticate(:email => email, :password => password) if password
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
