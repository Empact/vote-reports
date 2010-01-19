class SenateTerm < PoliticianTerm
  attr_accessible :politician, :senate_class, :state, :started_on, :ended_on, :created_on, :updated_on, :url, :party
  validates_presence_of :senate_class, :state
end
