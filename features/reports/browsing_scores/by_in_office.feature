Feature: Browsing Report Scores by State
  In order to find report scores for my representative
  As a user
  I want to view a report's scores for in-office reps only

  Background:
    Given I have a personal report named "Active Report"
    And an un-voted, current-congress bill named "Bovine Security Act of 2009"
    And the following politician records:
      | name                  |
      | Michael Burgess       |
      | J. Kerrey             |
      | John Cornyn           |
      | Kay Hutchison         |
      | Connie Mack           |
      | Neil Abercrombie      |
    And the following representative term records:
      | name                  | state | district | in_office |
      | Michael Burgess       | TX    | 26       | true      |
      | J. Kerrey             | TX    | 11       | false     |
      | Neil Abercrombie      | NY    | 7        | true      |
    And the following senate term records:
      | name                  | state | in_office |
      | John Cornyn           | TX    | true      |
      | Kay Hutchison         | TX    | false     |
      | Connie Mack           | OH    | true      |
    And the following district zip code records:
      | state | district | zip_code |
      | TX    | 26       | 75028    |
      | TX    | 11       | 78704    |
      | NY    | 7        | 11111    |
    And bill "Bovine Security Act of 2009" has the following rolls:
      | roll_type                                            | voted_at     |
      | On Passage                                           | 2.years.ago  |
      | On the Cloture Motion                                | 1.year.ago   |
      | Passage, Objections of the President Notwithstanding | 6.months.ago |
    And bill "Bovine Security Act of 2009" has the following roll votes:
      | politician       | On Passage | On the Cloture Motion | Passage, Objections of the President Notwithstanding |
      | Michael Burgess  | + | + |   |
      | J. Kerrey        | P | - |   |
      | John Cornyn      | 0 | + |   |
      | Kay Hutchison    | - |   | + |
      | Connie Mack      |   |   | P |
      | Neil Abercrombie | - |   | - |
    And report "Active Report" has the following bill criterion:
      | bill                        | support |
      | Bovine Security Act of 2009 | true    |
    And I wait for delayed job to finish

  Scenario: User views scores for only in-office reps
    When I go to my report page for "Active Report"
    Then I should see the following scores:
      | politician           | score |
      | Michael Burgess      | 100   |
      | John Cornyn          | 76    |
      | Connie Mack          | 50    |
      | Neil Abercrombie     | 0     |
    And I should not see "J. Kerrey"
    And I should not see "Kay Hutchison"
    When I uncheck "In Office"
    And I press "Show Reps"
    Then I should see the following scores:
      | politician           | score |
      | Michael Burgess      | 100   |
      | J. Kerrey            | 24    |
      | John Cornyn          | 76    |
      | Kay Hutchison        | 53    |
      | Connie Mack          | 50    |
      | Neil Abercrombie     | 0     |
    When I fill in "Reps From" with "TX"
    When I check "In Office"
    And I press "Show Reps"
    Then I should see the following scores:
      | politician           | score |
      | Michael Burgess      | 100   |
      | John Cornyn          | 76    |
    And I should not see "J. Kerrey"
    And I should not see "Kay Hutchison"
    And I should not see "Neil Abercrombie"
    And I should not see "Connie Mack"
