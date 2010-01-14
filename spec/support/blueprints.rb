Fixjour :verify => false do
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

  define_builder(Roll) do |klass, overrides|
    klass.new(
      :congress => Congress.find_or_create_by_meeting(rand(200)),
      :subject => new_bill,
      :year => 2009,
      :number => rand(1000),
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
    klass.new(
      :politician => new_politician,
      :party => new_party
    )
  end

  define_builder(RepresentativeTerm) do |klass, overrides|
    overrides.process(:party) do |party|
      party = Party.find_or_create_by_name(party) if party.is_a?(String)
      overrides[:party] = party
    end

    klass.new(
      :politician => new_politician,
      :party => new_party,
      :state => UsState::US_STATES.rand.last,
      :district => rand(100)
    )
  end

  define_builder(SenateTerm) do |klass, overrides|
    klass.new(
      :politician => new_politician,
      :party => new_party,
      :senate_class => [1, 2, 3].rand,
      :state => UsState::US_STATES.rand.last
    )
  end

  def create_published_report(attrs = {})
    create_report(attrs).tap do |report|
      create_bill_criterion(:report => report)
    end
  end

  def create_scored_report(attrs = {})
    create_published_report(attrs).tap do |report|
      create_roll(:subject => report.bill_criteria.first.bill)
    end
  end
end
