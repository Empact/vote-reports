Factory.define :user do |f|
  f.email {Factory.next :email}
  f.username {Factory.next :username}
  f.password "password"
  f.password_confirmation "password"
end

Factory.define :report do |f|
  f.name { Factory.next :text }
  f.user {|u| u.association(:user) }
end

Factory.define :amendment do |f|
  f.title { Factory.next :text }
  f.bill {|u| u.association(:bill) }
end

Factory.define :congress do |f|
  f.meeting { Forgery(:basic).number(:at_most => 111) }
end

Factory.define :bill do |f|
  f.title { Factory.next :text }
  f.opencongress_id { Factory.next :opencongress_id }
  f.gov_track_id { Factory.next :gov_track_id }
  f.bill_type { "H.Res.3549"}
  f.sponsor {|s| s.association(:politician) }
  f.congress {|s| s.association(:congress) }
end

Factory.define :bill_criterion do |f|
  f.report {|r| r.association(:report) }
  f.bill {|b| b.association(:bill) }
end

Factory.define :politician do |f|
  f.first_name { Forgery(:name).first_name }
  f.last_name { Forgery(:name).last_name }
  f.gov_track_id { Factory.next :gov_track_id }
end

Factory.define :vote do |f|
  f.politician {|p| p.association(:politician) }
  f.roll {|b| b.association(:roll) }
  f.vote { %w[+ - P 0].rand }
end

Factory.define :roll do |f|
  f.congress {|s| s.association(:congress) }
  f.subject {|b| b.association(:bill) }
  f.opencongress_id { Factory.next :opencongress_id }
end

Factory.define :representative_term do |f|
  f.congress { Congress.find_or_create_by_meeting(111) }
end

Factory.define :senate_term do |f|
  f.congress { Congress.find_or_create_by_meeting(111) }
end

Factory.sequence :text do |n|
  "#{n}#{Forgery(:basic).text}"
end

Factory.sequence :opencongress_id do |n|
  "#{(Bill.last.try(:opencongress_id) || 1).to_i + 1}"
end

Factory.sequence :gov_track_id do |n|
  "#{(Politician.last.try(:gov_track_id) || '300001').to_i + 1}"
end

Factory.sequence :email do |n|
  "#{n}#{Forgery(:internet).email_address}"
end

Factory.sequence :username do |n|
  "#{n}#{Forgery(:internet).user_name}"
end