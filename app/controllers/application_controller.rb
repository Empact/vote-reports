# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include LocationsHelper

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  geocode_ip_address

  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

  def permission_denied
    if current_user
      flash[:error] = 'Sorry, you are not allowed to the requested page.'
      notify_exceptional("User #{current_user.inspect} attempted to access protected page #{request.path}")
      respond_to do |format|
        format.html { redirect_to('/') }
        format.xml  { head :unauthorized }
        format.js   { head :unauthorized }
      end
    else
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_path(:return_to => request.path)
    end
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
