class UserSession < Authlogic::Session::Base
  pds_url Settings.login.pds_url
  calling_system Settings.login.calling_system
  anonymous true
  redirect_logout_url Settings.login.redirect_logout_url
  
  def attempt_sso?
    (Rails.env.development? || Rails.env.test?) ? false : super
  end
end