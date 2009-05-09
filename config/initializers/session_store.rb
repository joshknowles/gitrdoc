# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gitrdoc_session',
  :secret      => '9e3f77fe9470d13e58996d20b6c617ac360b44a0c39968e9809f0c9e91c62893ef1efe5991549c4db9ca10e8002a7507adae264f7cc4c646922657b9ed1241a3'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
