class CreateUsStates < ActiveRecord::Migration
  def self.up
    create_table :us_states, :force => true do |t|      
      t.string :abbreviation, :null => false, :limit => 2
      t.string :full_name, :null => false
      t.timestamps
    end

    UsState.create(:abbreviation => 'AL', :full_name => 'Alabama')
    UsState.create(:abbreviation => 'AK', :full_name => 'Alaska')
    UsState.create(:abbreviation => 'AZ', :full_name => 'Arizona')
    UsState.create(:abbreviation => 'AR', :full_name => 'Arkansas')
    UsState.create(:abbreviation => 'CA', :full_name => 'California')
    UsState.create(:abbreviation => 'CO', :full_name => 'Colorado')
    UsState.create(:abbreviation => 'CT', :full_name => 'Connecticut')
    UsState.create(:abbreviation => 'DE', :full_name => 'Delaware')
    UsState.create(:abbreviation => 'FL', :full_name => 'Florida')
    UsState.create(:abbreviation => 'GA', :full_name => 'Georgia')
    UsState.create(:abbreviation => 'HI', :full_name => 'Hawaii')
    UsState.create(:abbreviation => 'ID', :full_name => 'Idaho')
    UsState.create(:abbreviation => 'IL', :full_name => 'Illinois')
    UsState.create(:abbreviation => 'IN', :full_name => 'Indiana')
    UsState.create(:abbreviation => 'IA', :full_name => 'Iowa')
    UsState.create(:abbreviation => 'KS', :full_name => 'Kansas')
    UsState.create(:abbreviation => 'KY', :full_name => 'Kentucky')
    UsState.create(:abbreviation => 'LA', :full_name => 'Louisiana')
    UsState.create(:abbreviation => 'ME', :full_name => 'Maine')
    UsState.create(:abbreviation => 'MD', :full_name => 'Maryland')
    UsState.create(:abbreviation => 'MA', :full_name => 'Massachusetts')
    UsState.create(:abbreviation => 'MI', :full_name => 'Michigan')
    UsState.create(:abbreviation => 'MN', :full_name => 'Minnesota')
    UsState.create(:abbreviation => 'MS', :full_name => 'Mississippi')
    UsState.create(:abbreviation => 'MO', :full_name => 'Missouri')
    UsState.create(:abbreviation => 'MT', :full_name => 'Montana')
    UsState.create(:abbreviation => 'NE', :full_name => 'Nebraska')
    UsState.create(:abbreviation => 'NV', :full_name => 'Nevada')
    UsState.create(:abbreviation => 'NH', :full_name => 'New Hampshire')
    UsState.create(:abbreviation => 'NJ', :full_name => 'New Jersey')
    UsState.create(:abbreviation => 'NM', :full_name => 'New Mexico')
    UsState.create(:abbreviation => 'NY', :full_name => 'New York')
    UsState.create(:abbreviation => 'NC', :full_name => 'North Carolina')
    UsState.create(:abbreviation => 'ND', :full_name => 'North Dakota')
    UsState.create(:abbreviation => 'OH', :full_name => 'Ohio')
    UsState.create(:abbreviation => 'OK', :full_name => 'Oklahoma')
    UsState.create(:abbreviation => 'OR', :full_name => 'Oregon')
    UsState.create(:abbreviation => 'PW', :full_name => 'Palau')
    UsState.create(:abbreviation => 'PA', :full_name => 'Pennsylvania')
    UsState.create(:abbreviation => 'RI', :full_name => 'Rhode Island')
    UsState.create(:abbreviation => 'SC', :full_name => 'South Carolina')
    UsState.create(:abbreviation => 'SD', :full_name => 'South Dakota')
    UsState.create(:abbreviation => 'TN', :full_name => 'Tennessee')
    UsState.create(:abbreviation => 'TX', :full_name => 'Texas')
    UsState.create(:abbreviation => 'UT', :full_name => 'Utah')
    UsState.create(:abbreviation => 'VT', :full_name => 'Vermont')
    UsState.create(:abbreviation => 'VA', :full_name => 'Virginia')
    UsState.create(:abbreviation => 'WA', :full_name => 'Washington')
    UsState.create(:abbreviation => 'WV', :full_name => 'West Virginia')
    UsState.create(:abbreviation => 'WI', :full_name => 'Wisconsin')
    UsState.create(:abbreviation => 'WY', :full_name => 'Wyoming')

    UsState.create(:abbreviation => 'GU', :full_name => 'Guam')
    UsState.create(:abbreviation => 'PR', :full_name => 'Puerto Rico')
    UsState.create(:abbreviation => 'PI', :full_name => 'Philippine Islands')
    UsState.create(:abbreviation => 'MP', :full_name => 'Northern Mariana Islands')
    UsState.create(:abbreviation => 'MH', :full_name => 'Marshall Islands')
    UsState.create(:abbreviation => 'AS', :full_name => 'American Samoa')
    UsState.create(:abbreviation => 'DC', :full_name => 'District of Columbia')
    UsState.create(:abbreviation => 'FM', :full_name => 'Federated States of Micronesia')
    UsState.create(:abbreviation => 'VI', :full_name => 'Virgin Islands')

    UsState.create(:abbreviation => 'OL', :full_name => 'Territory of Orleans')
    UsState.create(:abbreviation => 'DK', :full_name => 'Territory of Dakota')

    UsState.create(:abbreviation => 'AE', :full_name => 'Armed Forces Africa, Canada, Europe and Middle East')
    UsState.create(:abbreviation => 'AA', :full_name => 'Armed Forces Americas (except Canada)')
    UsState.create(:abbreviation => 'AP', :full_name => 'Armed Forces Pacific')
  end

  def self.down
    drop_table :us_states
  end
end
