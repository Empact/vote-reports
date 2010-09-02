class Reports::EmbedsController < ApplicationController
  before_filter :load_report
  layout nil

  def show
    @scores = @report.scores.for_politicians(sought_politicians).paginate :page => params[:page], :per_page => 3
  end

  private

  def load_report
    @report =
      if params[:user_id]
        User.find(params[:user_id]).reports.find(params[:report_id])
      else
        InterestGroup.find(params[:interest_group_id]).report
      end
  end
end
