class User < ActiveRecord::Base
  is_gravtastic!
  has_friendly_id :username, :use_slug => true

  acts_as_authentic

  has_many :reports
  def personalized_report
    reports.personalized.first
  end
  def create_personalized_report
    personalized_report || reports.create!(
      :name => "#{username}'s Personalized Report",
      :description => "This report is composed of the all the reports your following",
      :state => 'personalized')
  end

  has_many :report_follows
  has_many :followed_reports, :through => :report_follows, :source => :report

  validates_uniqueness_of :username, :email, :case_sensitive => false
  validate :username_not_reserved

  state_machine :initial => :active do
    event :disable do
      transition :active => :disabled
    end
  end

  class << self
    def find_by_username_or_email(login)
      find_by_smart_case_login_field(login) || find_by_email(login)
    end
  end

  def admin?
    false
  end

  def follows?(report)
    followed_reports.include?(report)
  end

private

  def username_not_reserved
    if %w[new edit].include?(username.to_s.downcase)
      errors.add(:username, "is reserved")
    end
  end
end
