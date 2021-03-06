class Users::ReportsController < ApplicationController
  filter_resource_access nested_in: :users

  def index
    @reports = @user.reports.published

    respond_to do |format|
      format.html
      format.json {
        render json: @reports
      }
    end
  end

  def show
    @scores = @report.scores.for_politicians(sought_politicians).by_score
    respond_to do |format|
      format.html {
        unless request.path.start_with?(user_report_path(@user, @report))
          redirect_to user_report_path(@user, @report), status: 301
          return
        end
        @causes = @report.causes.limit(3)
        @subjects = @report.subjects.for_tag_cloud.except(:select).select("DISTINCT(subjects.*), SUM(report_subjects.count) AS count").limit(3)
      }
      format.js {
        render partial: 'reports/scores/table', locals: {
          report: @report, scores: @scores, target_path: user_report_path(@user, @report)
        }
      }
      format.json {
        render json: @report.as_json(include: :causes)
      }
    end
  end

  def edit
    if request.path != edit_user_report_path(@user, @report)
      redirect_to edit_user_report_path(@user, @report), status: 301
      return
    end
  end

  def update
    if @report.update_attributes(params[:report])
      flash[:notice] = "Successfully updated report."
      redirect_to [@user, @report]
    else
      render action: 'edit'
    end
  end

  def new
    @report = @user.reports.build
  end

  def create
    @report = @user.reports.build(params[:report])
    if @report.save
      flash[:notice] = "Successfully created report."
      redirect_to edit_user_report_path(@user, @report, new_report: true, anchor: 'Add_Bills')
    else
      render action: 'new'
    end
  end

  def destroy
    @report.destroy
    flash[:notice] = "Successfully deleted report."
    redirect_to user_reports_path(@user)
  end

  private

  def load_user
    @user = User.friendly.find(params[:user_id])
  end

  def load_report
    @report = @user.reports.except_personal.friendly.find(params[:id])
  end

  def permission_denied_path
    if permitted_to?(:show, @report, context: :users_reports)
      user_report_path(params[:user_id], params[:id])
    else
      user_reports_path(params[:user_id])
    end
  end
end
