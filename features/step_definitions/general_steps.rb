Then /^I should see error messages$/ do
  Then %{I should see "There were problems with the following fields"}
end

Given /^the following (.+) records?:$/ do |type, table|
  table.hashes.each do |row|
    send "create_#{type.to_s.gsub(' ', '_').underscore}", row.symbolize_keys
  end
  Politician.update_current_office_status! if type.include?(' term')
end

When /^I wait (\d+) seconds$/ do |seconds|
  print seconds
  sleep seconds.to_i
end

When /^I wait for delayed job to finish$/ do
  Delayed::Worker.new(:quiet => true).work_off(1)
end

When /^I console$/ do
  console_for(binding)
end

When /^I debug$/ do
  require 'ruby-debug'
  debugger
  x = 1 + 1
end

Then /^I should( not|) see the button "(.*)"$/ do |should_not, button_text|
  selector = "[value='#{button_text.strip}'][type=submit]"
  if should_not.present?
    page.should_not have_css(selector)
  else
    page.should have_css(selector)
  end
end

Then /^I should( not|) see the image "(.*)"$/ do |should_not, file_name|
  selector = "img[src*='/#{file_name.strip}?']"
  if should_not.present?
    page.should_not have_css(selector)
  else
    page.should have_css(selector)
  end
end
