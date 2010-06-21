class District < ActiveRecord::Base
  composed_of :level, :mapping => %w(level level), :class_name => 'District::Level'

  named_scope :lookup, lambda {|geoloc|
    {:conditions => ["ST_Contains(the_geom, GeometryFromText('POINT(? ?)', -1))",
      geoloc.lng, geoloc.lat]}
  }
  named_scope :level, lambda {|level|
    if level.present?
      {:conditions => {:level => level}}
    else
      {}
    end
  }

  Level.levels.each do |level|
    named_scope level, :conditions => {:level => level}
  end

  def polygon
    @polygon ||= the_geom[0]
  end
  def linear_ring
    @linear_ring ||= the_geom[0][0]
  end

  def display_name
    if /^\d*$/ =~ name
      "#{state_name} #{name.to_i.ordinalize}"
    else
      "#{state_name} #{name}"
    end
  end

  def full_name
    "#{display_name} #{level.description}"
  end

  FIPS_CODES = {
    "01" => "AL",
    "02" => "AK",
    "04" => "AZ",
    "05" => "AR",
    "06" => "CA",
    "08" => "CO",
    "09" => "CT",
    "10" => "DE",
    "11" => "DC",
    "12" => "FL",
    "13" => "GA",
    "15" => "HI",
    "16" => "ID",
    "17" => "IL",
    "18" => "IN",
    "19" => "IA",
    "20" => "KS",
    "21" => "KY",
    "22" => "LA",
    "23" => "ME",
    "24" => "MD",
    "25" => "MA",
    "26" => "MI",
    "27" => "MN",
    "28" => "MS",
    "29" => "MO",
    "30" => "MT",
    "31" => "NE",
    "32" => "NV",
    "33" => "NH",
    "34" => "NJ",
    "35" => "NM",
    "36" => "NY",
    "37" => "NC",
    "38" => "ND",
    "39" => "OH",
    "40" => "OK",
    "41" => "OR",
    "42" => "PA",
    "44" => "RI",
    "45" => "SC",
    "46" => "SD",
    "47" => "TN",
    "48" => "TX",
    "49" => "UT",
    "50" => "VT",
    "51" => "VA",
    "53" => "WA",
    "54" => "WV",
    "55" => "WI",
    "56" => "WY",
    "60" => "AS",
    "64" => "FM",
    "66" => "GU",
    "68" => "MH",
    "69" => "MP",
    "70" => "PW",
    "72" => "PR",
    "74" => "UM",
    "78" => "VI"
  }
end