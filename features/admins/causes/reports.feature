Feature: Managing Cause Reports
  In order to compose a causes scores
  As an admin
  I want to add/remove reports to causes

  Background:
    Given an admin named "Admin"
    And a published report named "Brady Campaign to Prevent Gun Violence"
    And a cause named "Gun Control"
    When I log in as "Admin/password"

  Scenario: Add report to cause
    When I go to the cause page for "Gun Control"
    And I follow "Reports" within "#content"
    And I follow "Add Reports"
    And I fill in "Search Reports" with "Brady"
    And I press "Search" within "#content"
    Then I should see "Brady Campaign to Prevent Gun Violence"
    And I check "Support"
    And I press "Save"
    Then I should see "Successfully added reports to cause"
    And I should be on the cause page for "Gun Control"
    When I follow "Reports" within "#content"
    Then I should see "Brady Campaign to Prevent Gun Violence"

  Scenario: Remove report from cause
    Given cause "Gun Control" includes report "Brady Campaign to Prevent Gun Violence"
    When I go to the cause page for "Gun Control"
    And I follow "Reports" within "#content"
    Then I should see "Brady Campaign to Prevent Gun Violence"
    And I follow "Remove"
    Then I should see "Successfully removed report"
    And I should be on the cause page for "Gun Control"
    And I should not see "Brady Campaign to Prevent Gun Violence"
