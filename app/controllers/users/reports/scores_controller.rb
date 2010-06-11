class Users::Reports::ScoresController < ApplicationController
  before_filter :load_report

  def index
    @scores = @report.scores.for_politicians(sought_politicians)
    respond_to do |format|
      format.html {
        render :layout => false
      }
      format.js {
        render :partial => 'reports/scores/table', :locals => {
          :report => @report, :scores => @scores,
          :reset_path => user_report_scores_path(@user, @report, :representing => '')
        }
      }
    end
  end

  def show
    @score = @report.scores.find(params[:id])
    respond_to do |format|
      format.html
      format.js {
        render :layout => false
      }
    end
  end

  private

  def load_report
    @user = User.find(params[:user_id])
    @report = @user.reports.find(params[:report_id], :scope => @user)
  end
end
