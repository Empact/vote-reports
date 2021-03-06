namespace :gov_track do
  namespace :politicians do
    desc "Process Politicians"
    task unpack: :'gov_track:support' do
      def party(name)
        return nil if name.blank? || Party::BLACKLIST.include?(name)
        @parties ||= Party.all.index_by(&:name)
        @parties.fetch(name) do
          @parties[name] = Party.create(name: name)
        end
      end

      def district(state, district)
        @districts ||= CongressionalDistrict.all(select: 'id,us_state_id,district_number').index_by {|d| [d.us_state_id, d.district_number] }
        state = UsState.find_by_abbreviation!(state)
        district = district.to_i
        district = nil if district == -1
        @districts.fetch([state.id, district]) do
          @districts[[state.id, district]] = CongressionalDistrict.create!(state: state, district_number: district)
        end
      end

      def politician(gov_track_id)
        @politicians ||= Politician.all(include: [:representative_terms, :senate_terms, :presidential_terms]).index_by(&:gov_track_id)
        @politicians.fetch(gov_track_id.to_i) do
          @politicians[gov_track_id.to_i] = Politician.new(gov_track_id: gov_track_id)
        end
      end

      rescue_and_reraise do
        data_path = ENV['MEETING'] ? "us/#{ENV['MEETING']}/people.xml" : "us/people.xml"
        doc = Nokogiri::XML(open(gov_track_path(data_path)))

        ActiveRecord::Base.transaction do
          doc.xpath('people/person').each do |person|
            attrs = {
                'lastname' => 'last_name',
                'middlename' => 'middle_name',
                'firstname' => 'first_name',
                'bioguideid' => 'bioguide_id',
                'metavidid' => 'metavid_id',
                'osid' => 'open_secrets_id',
                'birthday' => 'birthday',
                'gender' => 'gender',
                'religion' => 'religion',
                'id' => 'gov_track_id'
              }.inject({}) do |attrs, (attr, method)|
                attrs[method] = person[attr] if person[attr].present?
                attrs
            end
            politician =
              if pol = Politician.find_by_gov_track_id(attrs['gov_track_id'])
                pol.update_attributes!(attrs)
                pol
              else
                Politician.create!(attrs)
              end
            representative_terms = politician.representative_terms.index_by(&:started_on)
            senate_terms = politician.senate_terms.index_by(&:started_on)
            presidential_terms = politician.presidential_terms.index_by(&:started_on)

            person.xpath('role').each do |role|
              attrs = {
                'startdate' => 'started_on',
                'enddate' => 'ended_on',
                'url' => 'url',
                'party' => 'party'
              }.inject({}) do |attrs, (attr, method)|
                attrs[method] = role[attr].to_s if role[attr].present?
                attrs
              end
              attrs['party'] = party(attrs.delete('party'))
              attrs.symbolize_keys!

              case role['type']
              when 'rep'
                attrs.merge!(congressional_district: district(role['state'], role['district']))
                representative_terms[role['startdate'].to_date].tap do |term|
                  term && term.update_attributes(attrs)
                end || politician.representative_terms.create(attrs)
              when 'sen'
                attrs.merge!(senate_class: role['class'], state: us_state(role['state']))
                senate_terms[role['startdate'].to_date].tap do |term|
                  term && term.update_attributes(attrs)
                end || politician.senate_terms.create(attrs)
              when 'prez'
                presidential_terms[role['startdate'].to_date].tap do |term|
                  term && term.update_attributes(attrs)
                end || politician.presidential_terms.create(attrs)
              else
                raise role.inspect
              end.tap do |term|
                $stdout.print "P" if term.party.nil?
              end
            end

            $stdout.print "."
          end
          $stdout.flush
          puts
        end
      end
    end
  end
end
