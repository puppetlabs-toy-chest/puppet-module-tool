# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_forge_session',
  :secret      => 'e13349cf146fc3dd9037e7e32c6263877f4d4d5722fc465b6273225dc0967f23ca47b2ea18597e7070a397a79d997cf4ad87c6dcfb8b30475f181b7322ab1d67'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
