class SiteController < ApplicationController

  def index
    @recent_reports = Report.published.by_updated_at.paginate(:page => params[:page], :include => :user)
  end

  def about
  end

end
