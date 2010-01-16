class Bill < ActiveRecord::Base
  default_scope :include => :titles
  named_scope :by_introduced_on, :order => 'introduced_on DESC'
  named_scope :with_title, lambda {|title|
    {:select => 'DISTINCT bills.*', :joins => :titles, :conditions => {:'bill_titles.title' => title}}
  }

  has_friendly_id :opencongress_id

  searchable do
    text :summary, :gov_track_id, :opencongress_id, :bill_number
    text :subjects do
      subjects.map(&:name) * ' '
    end
    text :bill_type do
      [bill_type.short_name, bill_type.long_name].join(' ')
    end
    text :titles do
      titles.map(&:title) * ' '
    end
    text :introduced_on do
      introduced_on.to_s(:long)
    end
    integer :bill_number
    boolean :old_and_unvoted do
      congress.meeting != Congress.current_meeting \
        && rolls.empty?
    end
    time :introduced_on
  end

  class << self
    def reindex(opts = {})
      super(opts.reverse_merge(:include => [:titles, :rolls, :congress]))
    end
  end

  belongs_to :congress

  belongs_to :sponsor, :class_name => 'Politician'
  has_many :cosponsorships
  has_many :cosponsors, :through => :cosponsorships, :source => :politician

  has_many :bill_subjects
  has_many :subjects, :through => :bill_subjects

  has_many :committee_actions, :class_name => 'BillCommitteeActions'
  has_many :committees, :through => :committee_actions

  has_many :titles, :class_name => 'BillTitle'
  has_many :bill_criteria, :dependent => :destroy
  has_many :amendments, :dependent => :destroy
  has_many :rolls, :as => :subject, :dependent => :destroy
  has_many :votes, :through => :rolls
  def politicians
    Politician.scoped(:select => 'DISTINCT politicians.*', :joins => {:votes => :roll}, :conditions => {
      :'rolls.subject_id' => self, :'rolls.subject_type' => 'Bill'
    }).extend(Vote::Support)
  end

  composed_of :bill_type

  validates_format_of :gov_track_id, :with => /[a-z]+\d\d\d-\d+/
  validates_format_of :opencongress_id, :with => /\d\d\d-[a-z]+\d+/

  class << self
    def paginated_search(params)
      search do
        fulltext params[:q]
        paginate :page => params[:page], :per_page => Bill.per_page
        if params[:exclude_old_and_unvoted]
          without :old_and_unvoted, true
        end
      end
    end
  end

  def opencongress_url
    # As of the 111th, OpenCongress only maintains pages for bills for the current meeting
    "http://www.opencongress.org/bill/#{opencongress_id}/show" if congress.current?
  end

  def inspect
    %{#<Bill #{gov_track_id} - "#{titles.first}">}
  end

  def ref
    "#{bill_type}#{bill_number}"
  end

  def congress=(congress)
    if !new_record? && self.congress && congress != self.congress
      raise ActiveRecord::ReadOnlyRecord, "Can't change bill congress"
    end
    self[:congress_id] = congress.id
  end

  def bill_type=(bill_type)
    if !new_record? && self[:bill_type] && BillType.valid_types.include?(self.bill_type) && bill_type != self.bill_type
      raise ActiveRecord::ReadOnlyRecord, "Can't change bill type from #{self.bill_type} to #{bill_type}"
    end
    self[:bill_type] = bill_type
  end

  def bill_number=(bill_number)
    if !new_record? && self[:bill_number] && bill_number.to_i != self[:bill_number]
      raise ActiveRecord::ReadOnlyRecord, "Can't change bill number"
    end
    self[:bill_number] = bill_number
  end
end
