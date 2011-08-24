class InterestGroups::AmendmentCriteriaController < ApplicationController
  filter_resource_access :nested_in => :interest_groups
  before_filter :find_report

  def new
    if request.path != new_interest_group_amendment_criterion_path(@interest_group)
      redirect_to new_interest_group_amendment_criterion_path(@interest_group), :status => 301
      return
    end
    @bill = Bill.find(params[:bill_id])
    @amendments = @bill.amendments.order('chamber, number').page(params[:page])

    render :partial => 'reports/amendment_criteria/table', :locals => {
      :report => @report, :bill => @bill, :amendments => @amendments
    }
  end

  def create
    if @report.update_attributes(params[:report].slice(:amendment_criteria_attributes))
      flash[:notice] = "Successfully updated interest group amendments."
      redirect_to edit_interest_group_path(@interest_group, :anchor => 'Add_Bills')
    else
      render :action => 'new', :layout => false
    end
  end

  def index
    render :layout => false
  end

  def destroy
    @report.amendment_criteria.find(params[:id]).destroy
    flash[:notice] = "Successfully deleted amendment from agenda"
    redirect_to edit_interest_group_path(@interest_group, :anchor => 'Edit_Agenda')
  end

  private

  def find_report
    @report = @interest_group.report
  end

  def permission_denied_path
    interest_group_path(params[:interest_group_id])
  end
end
