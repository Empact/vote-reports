class Causes::ReportsController < ApplicationController
  filter_access_to :all
  before_filter :load_cause

  def new
    params[:subjects] ||= []
    @reports =
      if params[:q].present?
        Report.paginated_search(params).results
      else
        topical_reports.paginate :page => params[:page]
      end

    respond_to do |format|
      format.html
      format.js {
        render :partial => 'causes/reports/selection_table',
          :locals => {:cause => @cause, :reports => @reports, :id => 'cause_reports'}
      }
    end
  end

  def create
    if @cause.update_attributes(params[:cause].slice(:cause_reports_attributes))
      flash[:success] = "Successfully added reports to cause"
      redirect_to @cause
    else
      flash[:warning] = "Unable to add reports to cause"
      render :action => :new
    end
  end

  def destroy
    cause_report = @cause.cause_reports.find(params[:id])
    cause_report.destroy
    flash[:success] = 'Successfully removed report'
    redirect_to @cause
  end

  private

  def topical_reports
    Report.published.with_subjects(params[:subjects])
  end

  def load_cause
    @cause = Cause.find(params[:cause_id])
  end
end
