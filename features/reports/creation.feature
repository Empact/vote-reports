Feature: User create report
  In order to add content to the site
  A user
  Should be able to create a report

    Scenario: User creates a report
      Given I am signed in
      When I go to my profile page
      And I follow "Create a report"
      And I fill in "Name" with "My report"
      And I fill in "Description" with "I made this because I care"
      And I press "Save"
      Then I should see "Successfully created report."

    Scenario: User signs in to create a report
      Given I signed up as "email@person.com/password"
      When I go to the home page
      And I follow "Create a report"
      And I log in as "email@person.com/password"

    Scenario: User tries to create a report without a name
      Given I am signed in
      When I go to my profile page
      And I follow "Create a report"
      And I press "Save"
      Then I should see "Name can't be blank"