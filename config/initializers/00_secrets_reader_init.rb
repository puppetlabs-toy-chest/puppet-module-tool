# Read secrets
require 'secrets_reader'
SECRETS = SecretsReader.read

# Set cookie session
ActionController::Base.session = {
  :key    => SECRETS.session_name,
  :secret => SECRETS.session_secret,
}
