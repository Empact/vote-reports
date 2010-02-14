Fixjour :verify => false do
  STATES = [
      ["Alaska", "AK"], ["Alabama", "AL"], ["Arkansas", "AR"], ["Arizona", "AZ"], 
      ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["District of Columbia", "DC"], 
      ["Delaware", "DE"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Iowa", "IA"], 
      ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Kansas", "KS"], ["Kentucky", "KY"], 
      ["Louisiana", "LA"], ["Massachusetts", "MA"], ["Maryland", "MD"], ["Maine", "ME"], ["Michigan", "MI"], 
      ["Minnesota", "MN"], ["Missouri", "MO"], ["Mississippi", "MS"], ["Montana", "MT"], ["North Carolina", "NC"], 
      ["North Dakota", "ND"], ["Nebraska", "NE"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], 
      ["New Mexico", "NM"], ["Nevada", "NV"], ["New York", "NY"], ["Ohio", "OH"], ["Oklahoma", "OK"], 
      ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], 
      ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Virginia", "VA"], ["Vermont", "VT"], 
      ["Washington", "WA"], ["Wisconsin", "WI"], ["West Virginia", "WV"], ["Wyoming", "WY"]
  ]

  def us_state(state)
    return state if state.is_a?(UsState)
    state =STATES.assoc(state) || STATES.rassoc(state)
    UsState.find_by_abbreviation(state.last) || new_us_state(
      :full_name => state.first,
      :abbreviation => state.last,
      :state_type => 'state')
  end

  def meeting
    Forgery(:basic).number(:at_least => 103, :at_most => 111)
  end

  def bill_type
    Forgery(:basic).text(:at_least => 2, :at_most => 2, :allow_numeric => false, :allow_upper => false)
  end

  def bill_number
    Forgery(:basic).number(:at_most => 9999)
  end

  def opencongress_id
    "#{meeting}-#{bill_type}#{bill_number}"
  end

  def gov_track_id
    "#{bill_type}#{meeting}-#{bill_number}"
  end

  define_builder(Party) do |klass, overrides|
    klass.new(
      :name => Forgery(:basic).text
    )
  end

  define_builder(Committee) do |klass, overrides|
    klass.new(
      :display_name => Forgery(:basic).text,
      :code => Forgery(:basic).text
    )
  end

  define_builder(CommitteeMeeting) do |klass, overrides|
    klass.new(
      :committee => new_committee,
      :congress => new_congress,
      :name => Forgery(:basic).text
    )
  end

  define_builder(User) do |klass, overrides|
    klass.new(
      :email => Forgery(:internet).email_address,
      :username => Forgery(:basic).text,
      :password => 'password',
      :password_confirmation => 'password'
    )
  end

  define_builder(Report) do |klass, overrides|
    klass.new(:name => Forgery(:basic).text, :user => create_user)
  end

  define_builder(Amendment) do |klass, overrides|
    klass.new(
      :purpose => Forgery(:basic).text,
      :description => Forgery(:basic).text,
      :sponsor => send("create_#{%w[politician committee_meeting].rand}"),
      :bill => new_bill,
      :number => rand(1000),
      :offered_on => "12/13/2009",
      :chamber => ['h', 's'].rand,
      :congress => new_congress)
  end

  define_builder(Congress) do |klass, overrides|
    meeting = rand(200)
    meeting = rand(200) while Congress.find_by_meeting(meeting)
    klass.new(:meeting => meeting)
  end

  define_builder(BillTitle) do |klass, overrides|
    if BillTitleAs.count == 0
      [
        'enacted',
        'agreed to by house and senate',
        'passed house',
        'passed senate',
        'amended by senate',
        'amended by house',
        'reported to senate',
        'reported to house',
        'introduced',
        'popular'
      ].each_with_index do |as, index|
        BillTitleAs.create(:as => as, :sort_order => index)
      end
    end

    overrides.process(:as) do |as|
      overrides[:as] = BillTitleAs.find_by_as(as)
    end

    klass.new(
      :title => Forgery(:basic).text,
      :title_type => 'official',
      :as => BillTitleAs.find_by_as(["reported to senate", "agreed to by house and senate", "amended by house",
        "passed senate", "amended by senate", "introduced", "enacted", "reported to house", "passed house", 'popular'].rand),
      :bill => new_bill
    )
  end

  define_builder(Bill) do |klass, overrides|
    klass.new(
      :opencongress_id => opencongress_id,
      :gov_track_id => gov_track_id,
      :introduced_on => '12/13/2009',
      :bill_type => 'hr',
      :bill_number => bill_number,
      :sponsor => new_politician,
      :congress => Congress.find_or_create_by_meeting(rand(200))
    )
  end

  define_builder(BillCriterion) do |klass, overrides|
    klass.new(:report => new_report, :bill => new_bill, :support => true)
  end

  define_builder(Politician) do |klass, overrides|
    Party.find_or_create_by_name('Independent')

    overrides.process(:name) do |name|
      first_name, last_name = name.split(' ', 2)
      overrides.merge!(
        :first_name => first_name,
        :last_name => last_name)
    end

    klass.new(
      :gov_track_id => rand(1000000),
      :first_name => Forgery(:name).first_name,
      :last_name => Forgery(:name).last_name
    )
  end

  define_builder(Vote) do |klass, overrides|
    klass.new(
      :politician => new_politician,
      :roll => new_roll,
      :vote => %w[+ - P 0].rand
    )
  end

  define_builder(BillSupport) do |klass, overrides|
    klass.new(
      :politician => new_politician,
      :bill => new_bill
    )
  end

  define_builder(BillOpposition) do |klass, overrides|
    klass.new(
      :politician => new_politician,
      :bill => new_bill
    )
  end

  define_builder(Roll) do |klass, overrides|
    klass.new(
      :congress => Congress.find_or_create_by_meeting(rand(200)),
      :subject => new_bill,
      :year => rand(200) + 1810,
      :number => rand(10000),
      :where => ['house', 'senate'].rand,
      :result => Forgery(:basic).text,
      :required => Forgery(:basic).text,
      :question => Forgery(:basic).text,
      :roll_type => Forgery(:basic).text,
      :voted_at => '11/15/2003',
      :aye => rand(500),
      :nay => rand(500),
      :not_voting => rand(500),
      :present => rand(500)
    )
  end

  define_builder(PresidentialTerm) do |klass, overrides|
    politician_term_overrides(overrides, rand(2) * 4)

    started_on = rand(50).years.ago
    ended_on = started_on + 4.years

    klass.new(
      :politician => new_politician,
      :party => new_party,
      :started_on => started_on,
      :ended_on => ended_on
    )
  end

  define_builder(UsState) do |klass, overrides|
    state = STATES.rand
    
    klass.new(
      :full_name => state.first,
      :abbreviation => state.last,
      :state_type => 'state'
    )
  end

  define_builder(District) do |klass, overrides|
    klass.new(
      :state => new_us_state,
      :district => rand(40)
    )
  end

  define_builder(DistrictZipCode) do |klass, overrides|
    overrides.process(:district) do |district|
      overrides[:district] = District.find_or_create_by_us_state_id_and_district(us_state(overrides.send(:delete, :state)).id, district)
    end

    klass.new(
      :district => new_district,
      :zip_code => rand(99999)
    )
  end

  define_builder(RepresentativeTerm) do |klass, overrides|
    politician_term_overrides(overrides, 2)

    started_on = rand(50).years.ago
    ended_on = started_on + 2.years

    klass.new(
      :politician => new_politician,
      :party => new_party,
      :district => new_district,
      :started_on => started_on,
      :ended_on => ended_on
    )
  end

  define_builder(SenateTerm) do |klass, overrides|
    politician_term_overrides(overrides, 6)

    started_on = rand(50).years.ago
    ended_on = started_on + 6.years

    klass.new(
      :politician => new_politician,
      :party => new_party,
      :senate_class => [1, 2, 3].rand,
      :state => new_us_state,
      :started_on => started_on,
      :ended_on => ended_on
    )
  end

  def politician_term_overrides(overrides, years)
    overrides.process(:party) do |party|
      party = nil if party.blank?
      party = Party.find_or_create_by_name(party) if party.is_a?(String)
      overrides[:party] = party
    end

    overrides.process(:state) do |state|
      overrides[:state] = us_state(state)
    end

    overrides.process(:name) do |name|
      overrides[:politician] = Politician.with_name(name).first
    end

    overrides.process(:in_office) do |in_office|
      if in_office == 'true'
        overrides[:started_on] = 1.year.ago
        overrides[:ended_on] = 1.year.ago + years.years
      else
        overrides[:started_on] = 14.years.ago
        overrides[:ended_on] = 14.years.ago + years.years
      end
    end
  end

  alias create_empty_report create_report

  def create_unscored_report(attrs = {})
    create_report(attrs).tap do |report|
      create_bill_criterion(:report => report)
    end
  end

  def create_scored_report(attrs = {})
    create_unscored_report(attrs).tap do |report|
      roll = create_roll(:subject => report.bill_criteria.first.bill, :roll_type => "On Passage")
      Politician.all.each do |p|
        create_vote(:roll => roll, :politician => p, :vote => Vote::POSSIBLE_VALUES.rand)
      end
      report.rescore!
    end
  end

  def create_published_report(attrs = {})
    create_scored_report(attrs).tap do |report|
      report.publish
    end
  end
end
