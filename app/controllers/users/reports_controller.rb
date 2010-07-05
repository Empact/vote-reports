class Users::ReportsController < ApplicationController
  filter_resource_access :nested_in => :users

  def index
    @reports = @user.reports.published
  end

  def show
    if params[:id] != @report.to_param
      redirect_to user_report_path(@user, @report), :status => 301
      return
    end
  end

  def edit
    if !@report.friendly_id_status.best?
      redirect_to edit_user_report_path(@user, @report), :status => 301
      return
    end
  end

  def update
    if @report.update_attributes(params[:report])
      flash[:notice] = "Successfully updated report."
      redirect_to [@user, @report]
    else
      render :action => 'edit'
    end
  end

  def new
    @report = @user.reports.build
  end

  def create
    @report = @user.reports.build(params[:report])
    if @report.save
      flash[:notice] = "Successfully created report."
      redirect_to edit_user_report_path(@user, @report, :new_report => true, :anchor => 'Add_Bills')
    else
      render :action => 'new'
    end
  end

  def destroy
    @report.destroy
    flash[:notice] = "Successfully destroyed report."
    redirect_to user_reports_path(@user)
  end

  protected

  def permission_denied_path
    if permitted_to?(:show, @report, :context => :users_reports)
      user_report_path(params[:user_id], params[:id])
    else
      user_reports_path(params[:user_id])
    end
  end

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_report
    @report = @user.reports.find(params[:id], :scope => @user)
  end
end
