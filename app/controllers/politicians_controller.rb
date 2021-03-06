class PoliticiansController < ApplicationController

  def index
    @politicians = sought_politicians.by_birth_date.page(params[:page])

    respond_to do |format|
      format.html
      format.js {
        render partial: 'politicians/list', locals: {
          politicians: @politicians
        }
      }
    end
  end

  def show
    @politician = Politician.for_display.friendly.find(params[:id])
    if request.path != politician_path(@politician)
      redirect_to politician_path(@politician), status: 301 and return
    end
    @terms = @politician.continuous_terms
  end

  private

  def topical_scores
    @politician.report_scores.published.for_reports_with_subjects(params[:subjects])
  end
end
