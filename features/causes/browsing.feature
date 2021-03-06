Feature: Browsing Causes
  In order to discover causes of interest and their related reports
  As a user
  I want to browse causes

  Background:
    Given a cause named "Lollipops!"

  Scenario: Viewing the reports associated with a cause
    Given a published report named "Brady Campaign to Prevent Gun Violence"
    And cause "Lollipops!" includes report "Brady Campaign to Prevent Gun Violence"
    When I go to the cause reports page for "Lollipops!"
    And I follow "Brady Campaign to Prevent Gun Violence"
    Then I should be on the report page for "Brady Campaign to Prevent Gun Violence"
    When I follow "Lollipops!"
    Then I should be on the cause page for "Lollipops!"
