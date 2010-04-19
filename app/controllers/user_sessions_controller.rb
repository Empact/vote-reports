class UserSessionsController < ApplicationController
  filter_resource_access

  def new
    @return_to = params[:return_to]
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    
    if @user_session.registration_incomplete?
      @current_user_session = @user_session
      @user = @user_session.attempted_record
      flash[:notice] = "Alright! Almost there, just a few details to correct before we can move on:"
      render 'users/new_from_rpx'
    elsif @user_session.save
      if @user_session.new_registration?
        flash[:notice] = "That does it! As a new user, please review your registration details before continuing.."
        redirect_to edit_user_path(@user_session.record, :new_user => true)
      else
        flash[:notice] = "Logged in successfully"
        redirect_to (params[:return_to].present? ? params[:return_to] : @user_session.record)
      end
    else
      flash[:error] = "Failed to login or register."
      render :action => 'new'
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "You have been logged out"
    redirect_to root_path
  end
end
