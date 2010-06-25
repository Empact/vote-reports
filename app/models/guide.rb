class Guide < ActiveRecord::Base
  belongs_to :report
  belongs_to :user
  belongs_to :congressional_district

  has_friendly_id :secure_token

  has_many :guide_reports
  has_many :reports, :through => :guide_reports

  before_validation_on_create :initialize_report
  delegate :scores, :to => :report

  validates_presence_of :secure_token, :report

  delegate :scores, :rescore!, :to => :report

  alias_method :score_criteria, :guide_reports

  def immediate_scores
    return [] unless congressional_district.present? && reports.present?
    congressional_district.politicians.map do |politician|
      GuideScore.find_or_create_by_politician_id_and_report_ids(politician.id, reports.map(&:id))
    end
  end

  private

  def initialize_report
    self.secure_token = ActiveSupport::SecureRandom.hex(10)
    build_report(:name => secure_token, :guide => self).save!
  end
end
