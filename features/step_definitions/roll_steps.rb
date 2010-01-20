Given /^(bill "[^\"]*") has a roll on the question "([^\"]*)"$/ do |bill, question|
  create_roll(:subject => bill, :question => question)
end

Given /^(bill "[^\"]*") has the following rolls?:$/ do |bill, table|
  table.map_column!('voted_at') {|at| eval(at) }
  table.hashes.each do |hash|
    create_roll(hash.merge(:subject => bill))
  end
end
