When /^I log in as "(.*)\/(.*)"$/ do |email, password|
  When %{I go to the log in page}
  And %{I fill in "Email" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Log in"}
end

Given /^I am signed in$/ do
  @current_user = Factory(:user)
  When %{I log in as "#{@current_user.email}/#{@current_user.password}"}
end