class Politician < ActiveRecord::Base
  include Politician::GovTrack
  include Politician::SunlightLabs

  nilify_blanks

  has_many :representative_terms
  has_many :senate_terms

  IDENTITY_STRING_FIELDS = [
    :vote_smart_id, :bioguide_id, :eventful_id, :twitter_id, :email, :metavid_id,
    :congresspedia_url, :crp_id, :fec_id, :phone, :website, :youtube_url
  ].freeze
  IDENTITY_INTEGER_FIELDS = [:gov_track_id].freeze
  IDENTITY_FIELDS = (IDENTITY_STRING_FIELDS | IDENTITY_INTEGER_FIELDS).freeze

  validates_length_of IDENTITY_STRING_FIELDS, :minimum => 1, :allow_nil => true
  validates_uniqueness_of IDENTITY_FIELDS, :allow_nil => true
  validate :name_shouldnt_contain_nickname
  validate :terms_should_most_likely_be_from_the_same_state

  has_many :votes
  has_many :bills, :through => :votes do
    def supported
      scoped(:conditions => "votes.vote = true")
    end
    def opposed
      scoped(:conditions => "votes.vote = false")
    end
  end

  def full_name= full_name
    self.last_name, self.first_name = full_name.split(', ', 2)
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  private

  def name_shouldnt_contain_nickname
    errors.add(:first_name, "shouldn't contain nickname") if first_name =~ /\s?(.+)\s'(.+)'\s?/
  end

  def terms_should_most_likely_be_from_the_same_state
    rep_states = representative_terms.map(&:state).uniq
    senate_states = senate_terms.map(&:state).uniq

    if rep_states.present? && senate_states.present?
      most_states = rep_states.size > senate_states.size ? rep_states.size : senate_states.size
      if (rep_states | senate_states).size > most_states
        notify_exceptional(ArgumentError.new(
          "#{id} #{full_name} has different term states; senate: #{senate_states.join(', ')} representative: #{rep_states.join(', ')}"))
      end
    end
  end
end
