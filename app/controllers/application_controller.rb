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
    login_path
  end

  # For dev purposes
  def current_user_dev
    @current_user = User.new(:email => "user@nyu.edu", :firstname => "Ptolemy", :username => "ppXX", patron_status: "57")
    @current_user.admin_roles_mask = 1
    return @current_user
  end
  alias :current_user :current_user_dev if Rails.env.development?

  prepend_before_filter :passive_login
  def passive_login
    if !cookies[:_check_passive_login]
      cookies[:_check_passive_login] = true
      redirect_to passive_login_url
    end
  end

  # This makes sure you redirect to the correct location after passively
  # logging in or after getting sent back not logged in
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  # After signing out from the local application,
  # redirect to the logout path for the Login app
  def after_sign_out_path_for(resource_or_scope)
    if logout_path.present?
      logout_path
    else
      super(resource_or_scope)
    end
  end

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
    if current_user.nil?
      redirect_to login_url(origin: request.url) unless performed?
    elsif can? :create, Reservation
      flash[:error] ||= exception.message.html_safe
      if request.xhr?
        render "user_sessions/unauthorized_action", :alert => exception.message, :formats => :js
      else
        render "user_sessions/unauthorized_action", :alert => exception.message
      end
    else
      flash[:error] ||= exception.message.html_safe
      if request.xhr?
        render "user_sessions/unauthorized_patron", :alert => exception.message, :formats => :js
      else
        render "user_sessions/unauthorized_patron", :alert => exception.message
      end
    end
  end

  private

  def logout_path
    if ENV['LOGIN_URL'].present? && ENV['SSO_LOGOUT_PATH'].present?
      "#{ENV['LOGIN_URL']}#{ENV['SSO_LOGOUT_PATH']}"
    end
  end

  def passive_login_url
    "#{ENV['LOGIN_URL']}#{ENV['PASSIVE_LOGIN_PATH']}?client_id=#{ENV['APP_ID']}&return_uri=#{request_url_escaped}&login_path=#{login_path_escaped}"
  end

  def request_url_escaped
    CGI::escape(request.url)
  end

  def login_path_escaped
    CGI::escape("#{Rails.application.config.action_controller.relative_url_root}/login")
  end

end
