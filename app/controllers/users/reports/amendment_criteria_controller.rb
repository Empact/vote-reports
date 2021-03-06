class Users::Reports::AmendmentCriteriaController < ApplicationController
  before_filter :load_user
  before_filter :find_report
  filter_access_to :all, attribute_check: true, require: :edit, context: :reports

  def new
    @bill = Bill.find(params[:bill_id])
    @amendments = @bill.amendments.order('chamber, number').page(params[:page])

    render partial: 'reports/amendment_criteria/table', locals: {
      report: @report, bill: @bill, amendments: @amendments
    }
  end

  def create
    if @report.update_attributes(params[:report].slice(:amendment_criteria_attributes))
      flash[:notice] = "Successfully updated report amendments."
      redirect_to edit_user_report_path(@user, @report, anchor: 'Add_Bills')
    else
      render action: 'new', layout: false
    end
  end

  def index
    render layout: false
  end

  def destroy
    @report.amendment_criteria.find(params[:id]).destroy
    flash[:notice] = "Successfully deleted amendment from report agenda"
    redirect_to edit_user_report_path(@user, @report, anchor: 'Edit_Agenda')
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def find_report
    @report = @user.reports.find(params[:report_id])
  end

  def permission_denied_path
    user_report_path(params[:user_id], params[:report_id])
  end
end
