class InterestGroups::ScoresController < ApplicationController
  before_filter :load_interest_group

  def index
    @scores = @report.scores.for_politicians(sought_politicians).for_report_display

    respond_to do |format|
      format.html
      format.js {
        render :partial => 'reports/scores/table', :locals => {
          :report => @report, :scores => @scores, :target_path => interest_group_report_scores_path(@interest_group)
        }
      }
      format.json {
        render :json => @report.scores
      }
    end
  end

  def show
    @score = @report.scores.find(params[:id])
    respond_to do |format|
      format.html
      format.js {
        @js = true
        render :layout => false
      }
    end
  end

  private

  def load_interest_group
    @interest_group = InterestGroup.find(params[:interest_group_id], :include => :report)
    @report = @interest_group.report
  end
end
