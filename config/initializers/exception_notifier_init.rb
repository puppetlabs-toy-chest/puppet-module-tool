# Should the exception notification system be enabled?
EXCEPTION_NOTIFICATION_ENABLED =
  ! %w[ test development ].include?(RAILS_ENV) &&
  SECRETS.administrator_email != 'your@email.addr'

# Configure super_exception_notifier
if EXCEPTION_NOTIFICATION_ENABLED
  ExceptionNotifier.configure_exception_notifier do |config|
    config[:exception_recipients]    = [SECRETS.administrator_email]
    config[:sender_address]          = "error@#{Socket.gethostname}"
    config[:subject_prepend]         = "[forge ERROR] "
    config[:notify_error_codes]      = %w[ 405 500 503 ]
    config[:notify_other_errors]     = true
    config[:skip_local_notification] = false
  end

  # Add exception notification to controller
  Rails.configuration.after_initialize do
    ApplicationController.class_eval do
      include ExceptionNotifiable
      local_addresses.clear
    end
  end
end
