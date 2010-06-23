class Us::StatesController < ApplicationController
  def show
    @state = UsState.find(params[:id].upcase)

    respond_to do |format|
      format.html {
        @senators = @state.senators.in_office
        @representatives = @state.representatives_in_office.sort_by {|r| r.current_office.congressional_district.district }
      }
      format.js {
        render :partial => 'us/states/maps/map', :locals => {:state => @state}
      }
    end
  end
end
