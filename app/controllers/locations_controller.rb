class LocationsController < ApplicationController
  def new
    respond_to do |format|
      format.html
      format.js {
        render :layout => false
      }
    end
  end

  def create
    @geoloc =
      if params[:location].present?
        Geokit::Geocoders::MultiGeocoder.geocode(params[:location])
      elsif params[:autoloc]
        Geokit::LatLng.new(*params[:autoloc].values_at(:lat, :lng)).reverse_geocode
      end
    session[:geo_location_declared] = @geoloc.success?
    action =
      if !@geoloc.success?
        flash.now[:error] = %Q{Sorry, we were unable to understand this location. Could you clarify it?}
        'new'
      elsif !@geoloc.is_us?
        flash.now[:error] = %Q{Sorry, we currently only handle representatives for the United States of America.}
        'new'
      else
        if !%w[street address].include?(@geoloc.precision)
          flash.now[:notice] = %Q{For more accurate results, an address or intersection is best, but here's our best guess from what you've said.}
        else
          flash.now[:success] = "Successfully set location"
        end

        load_location_show_support

        session[:declared_location] = params[:location]
        session[:location] = geo_description(@geoloc) + " (#{@federal.display_name})"
        session[:congressional_district] = @federal.congressional_district
        session[:declared_geo_location] = @geoloc

        'show'
      end
    respond_to do |format|
      format.html {
        render :action => action
      }
      format.js {
        @js = true
        render :action => action, :layout => false
      }
    end
  end

  def show
    if params[:location].present? || params[:autoloc].present?
      create
      return
    end
    unless @geoloc = current_geo_location
      render :action => :new
      return
    end

    load_location_show_support

    respond_to do |format|
      format.html
      format.js {
        @js = true
        render :layout => false
      }
    end
  end

  def destroy
    flash[:success] = "Successfully cleared location"
    session.clear
    redirect_to params[:return_to] || root_path
  end

end
