class Embeds::ReportsController < ApplicationController
  layout 'widget'

  def show
    @location = current_geo_location || Location.random.first
    @politicians = Politician.from_location(@location).in_office_normal_form.all(:limit => 8)

    @report =
      if params[:id] == 'random'
        Report.published.with_scores_for(@politicians).random.first
      else
        Report.published.find(Integer(params[:id]))
      end

    @scores = @report.scores.for_politicians(@politicians).all
  end
end
