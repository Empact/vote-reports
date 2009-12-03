class Users::ReportsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  def index
    @user = User.find(params[:user_id])
    @reports = @user.reports
  end

  def show
    @user = User.find(params[:user_id])
    @report = @user.reports.find(params[:id])
  end

  def edit
    @user = User.find(params[:user_id])
    @report = @user.reports.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @report = @user.reports.find(params[:id])
    if @report.update_attributes(params[:report])
      flash[:notice] = "Successfully updated report."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def new
    @user = User.find(params[:user_id])
    @report = @user.reports.build
  end

  def create
    @user = User.find(params[:user_id])
    @report = @user.reports.build(params[:report])
    if @report.save
      flash[:notice] = "Successfully created report."
      redirect_to [@user, @report]
    else
      render :action => 'new'
    end
  end

  def destroy
    @user = User.find_by_param!(params[:user_id])
    @user.reports.find(params[:id]).destroy
    flash[:notice] = "Successfully destroyed report."
    redirect_to user_reports_url(@user)
  end
end
