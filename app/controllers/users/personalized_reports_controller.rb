class Users::PersonalizedReportsController < ApplicationController
  before_filter :is_current_user?

  def show
    @report = current_user.personalized_report
    if @report.nil?
      flash[:notice] = "You don't have a personalized report - you'll have to follow the reports of others to generate one."
      redirect_to user_path(current_user)
    end
  end
end
