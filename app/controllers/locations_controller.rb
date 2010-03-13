class LocationsController < ApplicationController
  def new
  end

  def create
    if zip_code?(params[:zip_code])
      flash[:success] = "Successfully set location!"
      session[:zip_code] = params[:zip_code]
      redirect_to params[:return_to] || root_path
    else
      flash[:error] = %Q{"#{params[:zip_code]}" doesn't look like a zip code.  Try again?}
      render :action => 'new'
    end
  end
end
