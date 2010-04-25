Feature: Editing Interest Group Images
  In order to add images to interest groups
  As an admin
  I want to edit the interest group image

  Background:
    Given I am signed in
    And I have the following published report:
      | name      | description                |
      | My Report | I made this because I care |

  Scenario: Navigating to the image edit page on an interest group
    When I go to my report page for "My Report"
    And I follow "Edit Report"
    And I follow "Edit Thumbnail"
    Then I should see "Replace Thumbnail"
    And I should be on the edit image page for the report "My Report"

  Scenario: Updating the image on an interest group
    When I go to the edit image page for the report "My Report"
    And I attach the file "public/images/gov_track_logo.png" to "image_thumbnail"
    And I press "Replace!"
    Then I should be on my report page for "My Report"
    And I should see the image "gov_track_logo.png"
