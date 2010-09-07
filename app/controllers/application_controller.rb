# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include LocationsHelper

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  geocode_ip_address

  helper_method :current_user_session, :current_user, :report_path_components, :report_path, :report_follows_path, :report_score_path, :report_bill_criteria_path, :new_report_amendment_criterion_path, :report_amendment_criteria_path, :report_embed_id
  filter_parameter_logging :password, :password_confirmation, :fb_sig_friends

  before_filter :basic_authenticate if Rails.env.staging?

  def permission_denied_path
    root_path
  end

  def permission_denied
    if current_user
      flash[:error] = 'You may not access this page'
      notify_hoptoad(RuntimeError.new("User #{current_user.inspect} attempted to access protected page #{request.path}"))
      respond_to do |format|
        format.html { redirect_to permission_denied_path }
        format.xml  { head :unauthorized }
        format.js   { head :unauthorized }
      end
    else
      flash[:notice] = "You must be logged in to access this page"
      new_params = {}
      if request.request_method && request.request_method != :get
        new_params.merge!(:method => request.request_method)
      end
      if params[:return_to]
        new_params.merge!(:return_to => params[:return_to])
      end

      return_path = request.path
      if new_params.present?
        return_path += (request.path.include?('?') ? '&' : '?') + new_params.to_param
      end

      redirect_to login_path(:return_to => return_path)
    end
  end

  def load_location_show_support(geoloc)
    @geoloc = geoloc
    @districts = District.lookup(@geoloc).sort_by {|d| d.level.sort_order }
    @federal = @districts.detect {|d| d.level.to_s == 'federal' }
    raise "No federal districts for #{geoloc.inspect}" unless @federal
    @politicians = Politician.for_districts(@districts).in_office_normal_form
  end

  def report_path(report, params = {})
    polymorphic_path(report_path_components(report), params)
  end

  def report_follows_path(report, params = {})
    polymorphic_path([report_path_components(report), :follows].flatten, params)
  end

  def report_bill_criteria_path(report, params = {})
    polymorphic_path([report_path_components(report), :bill_criteria].flatten, params)
  end

  def new_report_amendment_criterion_path(report, params = {})
    new_polymorphic_path([report_path_components(report), :amendment_criterion].flatten, params)
  end

  def report_amendment_criteria_path(report, params = {})
    polymorphic_path([report_path_components(report), :amendment_criteria].flatten, params)
  end

  def report_score_path(score, report = nil)
    if score.is_a?(GuideScore)
      guide_score_path(score.to_param)
    else
      polymorphic_path([report_path_components(report || score.report), score].flatten)
    end
  end

  def report_path_components(report)
    if report.user
      [report.user, report]
    else
      raise "No owner for report: #{report.inspect}" if report.owner.nil?
      report.owner
    end
  end

  def report_embed_id(report)
    dom_id(report, :votereports_embed)
  end

  def js_render(options = {})
    partial_html = render_to_string(options.except(:css))
    if options[:css]
      css_path = File.read(Rails.root.join("public/stylesheets/#{options[:css]}.css"))
      partial_html = TamTam.inline(:css => css_path, :body => partial_html)
    end
    partial_html.gsub(/class="(.*)"/, 'class="votereports_\1"').gsub(/id="(.*)"/, 'id="votereports_\1"').to_json
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

  def basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      User.find_by_username(username).try(:valid_password?, password)
    end
  end
end
