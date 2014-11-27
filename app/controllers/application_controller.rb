# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout Proc.new{ |controller| (controller.request.xhr?) ? false : "application" }

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Set the system timezone to the user timezone
  before_filter :set_timezone
  after_filter :set_timezone

  def set_timezone
    Time.zone = cookies[:timezone] || 'Eastern Time (US & Canada)'
  end

  def new_session_path(scope)
    new_user_session_path
  end


  # For dev purposes
  def current_user_dev
    @current_user = User.new(:email => "user@nyu.edu", :firstname => "Ptolemy", :username => "ppXX", patron_status: "57")
    @current_user.admin_roles_mask = 1
    return @current_user
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

  def get_hour_in_24(hours_hash)
    return (hours_hash[:ampm] == "pm" && hours_hash[:hour] != "12") ? hours_hash[:hour].to_i + 12 :
            (hours_hash[:ampm] == "am" && hours_hash[:hour] == "12") ? hour = 0 :
              hours_hash[:hour].to_i
  end

  def default_elasticsearch_options
    @default_elasticsearch_options ||= { :direction => (params[:direction] || 'asc'), :sort => (params[:sort] || sort_column.to_sym), :page => (params[:page] || 1), :per => (params[:per] || 20) }
  end

  # Manage access denied error messages from CanCan
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] ||= exception.message.html_safe
    if current_user.nil?
      redirect_to login_url unless performed?
    elsif can? :create, Reservation
      if request.xhr?
        render "user_sessions/unauthorized_action", :alert => exception.message, :formats => :js
      else
        render "user_sessions/unauthorized_action", :alert => exception.message, :formats => :js
      end
    else
      if request.xhr?
        render "user_sessions/unauthorized_patron", :alert => exception.message, :formats => :js
      else
        render "user_sessions/unauthorized_patron", :alert => exception.message
      end
    end
  end

end
