class CommitteeMeeting < ActiveRecord::Base
  belongs_to :committee
  belongs_to :congress

  def subcommittees
    CommitteeMeeting.scoped(
      :conditions => {
        :committee_id => committee.subcommittees,
        :congress_id => congress_id
      }
    )
  end

  has_many :memberships, :class_name => 'CommitteeMembership'
  has_many :members, :through => :memberships, :source => :politician

  validates_presence_of :committee, :congress
end
