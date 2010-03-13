Feature: User Location
  In order to offer scores relevant to the user
  A user
  Should have their location stored, and modifiable

  Scenario: User with no location stored can follow a link to set it
    When I go to the home page
    And I follow "Set your location!"
    And I fill in "Zip Code" with "75028"
    And I press "Save"
    Then I should be on the home page
    And I should see "Successfully set location"
    And I should see "Zip: 75028"

  @emulate_rails_javascript
  Scenario: User should be able to clear existing location
    Given my location is set to "75028"
    When I go to the home page
    And I follow "clear"
    Then I should see "Successfully cleared location"
    And I should not see "75028"
    And I should be on the home page
