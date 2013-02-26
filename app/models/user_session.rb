class UserSession < Authlogic::Session::Base
  pds_url Settings.login.pds_url
  calling_system Settings.login.calling_system
  anonymous true
  redirect_logout_url Settings.login.redirect_logout_url
  
  def additional_attributes
    h = {}
    return h unless pds_user
    h[:room_reserve_admin] = true if Settings.login.default_admins.include? pds_user.uid
    return h
  end
end