# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authpds::Controllers::AuthpdsController
  layout Proc.new{ |controller| (controller.request.xhr?) ? false : "application" }
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  check_authorization :unless => :peek_controller? # Enable CanCan

  # Set the system timezone to the user timezone 
  before_filter :set_timezone  
  after_filter :set_timezone

  def set_timezone
    Time.zone = cookies[:timezone] || 'Eastern Time (US & Canada)'
  end
  
  # For dev purposes
  def current_user_dev
   @current_user ||= User.find_by_username("ba36")
  end
  alias :current_user :current_user_dev if Rails.env.development?

  # Return boolean matching the url to find out if we are in the admin view
  def in_admin_view?
    !request.path.match("/admin").nil?
  end
  helper_method :in_admin_view?
  
  # Protect against SQL injection by forcing column to be an actual column name in the model
  def sort_column klass, default_column = "sort_order"
    klass.constantize.column_names.include?(params[:sort]) ? params[:sort] : default_column
  end
  protected :sort_column
  
  # Protect against SQL injection by forcing direction to be valid
  def sort_direction default_direction = "asc"
    %w[asc desc].include?(params[:direction]) ? params[:direction] : default_direction
  end
  helper_method :sort_direction
  protected :sort_direction
  
  # Manage access denied error messages from CanCan
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] ||= exception.message.html_safe
    if current_user.nil?
      redirect_to login_url unless performed?
    elsif can? :create, Reservation
      if request.xhr?
        render "user_sessions/unauthorized_action", :alert => exception.message, :formats => :js
      else
        render "user_sessions/unauthorized_action", :alert => exception.message
      end
    else
      if request.xhr?
        render "user_sessions/unauthorized_patron", :alert => exception.message, :formats => :js
      else
        render "user_sessions/unauthorized_patron", :alert => exception.message
      end 
    end
  end

  def peek_controller?
    (params[:controller] == "peek/results")
  end
  private :peek_controller?

end
