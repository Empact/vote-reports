class Cosponsorship < ActiveRecord::Base
  belongs_to :politician
  belongs_to :bill

  validates_presence_of :politician, :bill, :joined_on
  before_validation :populate_joined_on_if_missing, on: :create

  def verb
    if bill.sponsorship == self
      'introduced'
    else
      'cosponsored'
    end
  end

  # for compliance with Criterion & scoring
  def aye?
    true
  end
  def nay?
    false
  end
  def event_date
    bill.introduced_on
  end
  def subject
    bill
  end

  private

  def populate_joined_on_if_missing
    joined_on ||= bill.try(:introduced_on)
  end
end
