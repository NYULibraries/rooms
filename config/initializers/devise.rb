Devise.setup do |config|
  require 'devise/orm/active_record'
  config.secret_key = ENV['ROOMS_SECRET_TOKEN']
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.password_length = 8..128
  config.reset_password_within = 60.minutes
  config.sign_out_via = :get
  config.omniauth :nyulibraries,  ENV['APP_ID'], ENV['APP_SECRET']
end
