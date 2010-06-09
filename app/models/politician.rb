class Politician < ActiveRecord::Base
  include Politician::GovTrack
  include Politician::SunlightLabs

  has_friendly_id :full_name, :use_slug => true, :approximate_ascii => true

  has_many :representative_terms
  has_one :latest_representative_term, :class_name => 'RepresentativeTerm', :order => 'ended_on DESC'

  has_many :senate_terms
  has_one :latest_senate_term, :class_name => 'SenateTerm', :order => 'ended_on DESC'

  has_many :presidential_terms
  has_one :latest_presidential_term, :class_name => 'PresidentialTerm', :order => 'ended_on DESC'

  has_many :interest_group_ratings
  has_many :interest_group_reports, :through => :interest_group_ratings
  def rating_interest_groups
    InterestGroup.scoped(
      :select => 'DISTINCT interest_groups.*',
      :joins => {:reports => :ratings},
      :conditions => {:'interest_group_ratings.politician_id' => self})
  end

  def latest_term
    [latest_senate_term,
      latest_presidential_term,
      latest_representative_term].compact.sort_by(&:ended_on).last
  end

  def terms
    (
      representative_terms.all(:include => [:party, :district])  +
      senate_terms.all(:include => [:party, :state]) +
      presidential_terms.all(:include => :party)
    ).sort_by(&:ended_on).reverse
  end

  def continuous_terms
    ContinuousTerm.find_all_by_politician_id(id, :order => [['ended_on', 'desc']])
  end

  belongs_to :district
  belongs_to :state, :class_name => 'UsState', :foreign_key => :us_state_id
  def location
    district || state
  end

  searchable do
    text :name
    boolean :autocompletable do
      in_office?
    end
    boolean :visible do
      true
    end
    boolean :in_office do
      in_office?
    end
  end

  class << self
    def paginated_search(params)
      search do
        fulltext params[:term]
        if params[:except].present?
          without(params[:except])
        end
        paginate :page => params[:page]
      end
    end
  end

  IDENTITY_STRING_FIELDS = [
    :vote_smart_id, :bioguide_id, :eventful_id, :twitter_id, :email, :metavid_id,
    :congresspedia_url, :open_secrets_id, :crp_id, :fec_id, :phone, :website, :youtube_url
  ].freeze
  IDENTITY_INTEGER_FIELDS = [:gov_track_id].freeze
  IDENTITY_FIELDS = (IDENTITY_STRING_FIELDS | IDENTITY_INTEGER_FIELDS).freeze

  validates_length_of IDENTITY_STRING_FIELDS, :minimum => 1, :allow_nil => true
  validates_uniqueness_of IDENTITY_FIELDS, :allow_nil => true

  validate :name_shouldnt_contain_nickname
  before_validation :extract_nickname_from_first_name_if_present

  has_many :votes
  has_many :rolls, :through => :votes, :extend => Vote::Support

  has_many :report_scores
  has_many :reports, :through => :report_scores

  default_scope :include => :state

  belongs_to :current_office, :polymorphic => true
  named_scope :in_office, :conditions => 'politicians.current_office_id IS NOT NULL'
  named_scope :in_office_normal_form, lambda {
    {
      :select => 'DISTINCT politicians.*',
      :joins => [
        %{LEFT OUTER JOIN "representative_terms" ON representative_terms.politician_id = politicians.id},
        %{LEFT OUTER JOIN "senate_terms" ON senate_terms.politician_id = politicians.id},
        %{LEFT OUTER JOIN "presidential_terms" ON presidential_terms.politician_id = politicians.id}],
      :conditions => [
        '(((representative_terms.started_on, representative_terms.ended_on) OVERLAPS (DATE(:yesterday), DATE(:tomorrow))) OR ' \
        '((senate_terms.started_on, senate_terms.ended_on) OVERLAPS (DATE(:yesterday), DATE(:tomorrow))) OR ' \
        '((presidential_terms.started_on, presidential_terms.ended_on) OVERLAPS (DATE(:yesterday), DATE(:tomorrow))))',
        {:yesterday => Date.yesterday, :tomorrow => Date.tomorrow}
      ]
    }
  }
  class << self
    def update_current_office_status!
      Politician.transaction do
        Politician.update_all(:current_office_id => nil, :current_office_type => nil)
        Politician.in_office_normal_form.paginated_each do |politician|
          politician.update_attribute(:current_office, politician.latest_term)
        end
      end
    end
  end
  def in_office?
    !current_office_id.nil?
  end

  named_scope :with_name, lambda {|name|
    first, last = name.split(' ', 2)
    {:conditions => {:first_name => first, :last_name => last}}
  }
  named_scope :by_birth_date, :order => 'birthday DESC NULLS LAST'
  named_scope :by_district, :order => 'districts.district'
  named_scope :from_district, lambda {|districts|
    {:conditions => [
        "(senate_terms.us_state_id IN(?) OR representative_terms.district_id IN(?))",
         Array(districts).map(&:us_state_id), districts
      ], :joins => [
        %{LEFT OUTER JOIN "representative_terms" ON representative_terms.politician_id = politicians.id},
        %{LEFT OUTER JOIN "senate_terms" ON senate_terms.politician_id = politicians.id},
      ], :select => 'DISTINCT politicians.*'
    }
  }
  named_scope :from_state, lambda {|state|
    state = UsState.first(:conditions => ["abbreviation = :state OR UPPER(full_name) = :state", {:state => state.upcase}]) if state.is_a?(String)
    if state
      {:select => 'DISTINCT politicians.*', :conditions => [
        'senate_terms.us_state_id = ? OR districts.us_state_id = ?', state, state
      ], :joins => [
        %{LEFT OUTER JOIN "representative_terms" ON representative_terms.politician_id = politicians.id},
        %{LEFT OUTER JOIN "senate_terms" ON senate_terms.politician_id = politicians.id},
        %{LEFT OUTER JOIN "districts" ON representative_terms.district_id = districts.id},
      ]}
    else
      {:conditions => '0 = 1'}
    end
  }
  named_scope :representatives_from_state, lambda {|state|
    state = UsState.first(:conditions => ["abbreviation = :state OR UPPER(full_name) = :state", {:state => state.upcase}]) if state.is_a?(String)
    if state
      {
        :select => 'DISTINCT politicians.*, districts.district',
        :conditions => ['districts.us_state_id = ?', state],
        :joins => {:representative_terms => :district}
      }
    else
      {:conditions => '0 = 1'}
    end
  }

  class << self
    def from_zip_code(zip_code)
      from_district(District.with_zip(zip_code))
    end

    def from_city(address)
      from_district(District.for_city(address))
    end

    def from_location(location)
      results = scoped(:conditions => '0 = 1')
      results = from_zip_code(location.zip) if location.zip.present?
      results = from_city("#{location.city}, #{location.state}") if results.empty? && location.city.present?
      results = from_state(location.state) if results.empty? && location.state.present?
      results
    end

    def from(representing)
      if representing.blank?
        self
      elsif representing.is_a?(Geokit::GeoLoc)
        from_location(representing)
      else
        results = from_zip_code(representing)
        # try state first as it's much more restrictive search than city
        # and there are some misleading 2-character cities
        results = from_state(representing) if results.blank?
        results = from_city(representing) if results.blank?
        results = from_location(Geokit::Geocoders::MultiGeocoder.geocode(representing)) if results.blank?
        results
      end
    end
  end

  def full_name= full_name
    self.last_name, self.first_name = full_name.split(', ', 2)
  end

  def full_name
    [first_name, last_name].join(" ")
  end
  alias_method :name, :full_name

  class << self
    def update_titles!
      paginated_each do |politician|
        title = politician.latest_term.try(:title)
        if politician.title != title
          politician.update_attribute(:title, title)
        end
      end
    end
  end
  def short_title
    return '' if title.blank?
    if title == 'President'
      'Pres.'
    else
      "#{title.to(2)}."
    end
  end

  private

  def name_shouldnt_contain_nickname
    errors.add(:first_name, "shouldn't contain nickname") if first_name =~ /\s?(.+)\s'(.+)'\s?/
  end

  def extract_nickname_from_first_name_if_present
    if first_name =~ /\s?(.+)\s'(.+)'\s?/
      self.first_name = $1
      self.nickname = $2
    end
  end
end
