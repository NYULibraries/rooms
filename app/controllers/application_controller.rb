# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authpds::Controllers::AuthpdsController
  layout "application"
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Filter users to root if not admin
  def authenticate_admin
    if !is_admin
      redirect_to root_path and return unless performed?
    else
      return true
    end
  end
  
  # Authorize patron access to this application
  def authorize_patron
    if is_admin? or is_authorized? 
      return true
    elsif !current_user.nil?
      render 'user_sessions/unauthorized_patron'
    else
      redirect_to login_url unless performed?
    end
  end
  
  # For dev purposes
  def current_user_dev
   @current_user ||= User.find_by_username("ba36")
  end
  alias :current_user :current_user_dev if Rails.env == "development"

  # Return true if user is marked as admin
  def is_admin
  	if current_user.nil? or !current_user.user_attributes[:room_reserve_admin]
      return false
    else
      return true
    end
  end
  alias :is_admin? :is_admin
  helper_method :is_admin?
 
  # Is borrower type included in authorized borrower types
  def is_authorized
    (auth_types.include? current_user.user_attributes[:bor_type])
  end
  alias :is_authorized? :is_authorized
  helper_method :is_authorized?
  
  # Array of authorized borrower types
  def auth_types
    @auth_types ||= ["CB"]
  end
  
  # Return boolean matching the url to find out if we are in the admin view
  def is_in_admin_view
    !request.path.match("/admin").nil?
  end
  alias :is_in_admin_view? :is_in_admin_view
  helper_method :is_in_admin_view?

end
