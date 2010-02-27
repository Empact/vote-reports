# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  geocode_ip_address

  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

  private

  def sought_politicians
    if params[:from_where].present?
      Politician.from(params[:from_where])
    elsif !params.has_key?(:from_where) && session[:geo_location]
      params[:from_where] = session[:geo_location].full_address
      Politician.from(session[:geo_location])
    else
      Politician
    end.in_office(params[:in_office])
  end

  def login_required
    unless current_user
      #store_location #TODO: implement store location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_path(:return_to => request.path)
      return false
    end
  end

  def is_admin?
    return if login_required == false
    if !current_user.admin?
      notify_exceptional("User #{current_user.inspect} attempted to access protected page #{request.path}")
      flash[:notice] = "You may not access this page"
      redirect_to user_path(current_user)
      return false
    end
  end

  def is_current_user?
    return if login_required == false
    unless current_user.admin? || (current_user == User.find(params[:user_id] || params[:id]))
      notify_exceptional("User #{current_user.inspect} attempted to access protected page #{request.path}")
      flash[:notice] = "You may not access this page"
      redirect_to user_path(current_user)
      return false
    end
  end

  def is_report_owner
    return if login_required == false
    report_owner = User.find(params[:user_id])
    unless current_user.admin? || (current_user == report_owner)
      notify_exceptional("User #{current_user.inspect} attempted to access protected page #{request.path}")
      flash[:notice] = "You may not access this page"
      redirect_to user_report_path(report_owner, report_owner.reports.find(params[:report_id] || params[:id], :scope => report_owner))
      return false
    end
  end

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
