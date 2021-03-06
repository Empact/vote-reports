class Politicians::ReportsController < ApplicationController
  def index
    @politician = Politician.friendly.find(params[:politician_id])

    params[:subjects] ||= []
    if params[:term].present?
      @reports = Report.paginated_search(params)
      @reports.instance_variable_set(:@results, topical_scores.for_reports(@reports.results))
      @scores = @reports
    else
      @scores = topical_scores.page(params[:page])
    end

    @subjects = Subject.for_report(paginated_results(@scores).map(&:report)).for_tag_cloud.limit(20)

    respond_to do |format|
      format.html {
        render layout: false
      }
      format.js {
        render partial: 'politicians/scores/table', locals: {
          scores: @scores, replace: 'report_scores'
        }
      }
    end
  end

  private

  def topical_scores
    @politician.report_scores.for_published_reports.for_reports_with_subjects(params[:subjects]).by_score
  end
end
