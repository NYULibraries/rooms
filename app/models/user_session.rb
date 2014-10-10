class UserSession < Authlogic::Session::Base
  pds_url ENV['ROOMS_PDS_URL']
  calling_system ENV['ROOMS_PDS_URL']
  anonymous true
  redirect_logout_url ENV['ROOMS_REDIRECT_LOGOUT_URL']

  def attempt_sso?
    (Rails.env.development? || Rails.env.test?) ? false : super
  end
end
