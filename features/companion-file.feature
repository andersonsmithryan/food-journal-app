Feature: Companion file connection
  Ensures entry creation is tied to a connected companion file.

  @COMP-001
  Scenario: Disable new entry when no companion file is connected
    Given no companion file is connected
    When I view the entry selector
    Then the "New entry for today" button is disabled
    And the button indicates a companion file is required

  @deprecated
  @COMP-002
  Scenario: Prevent new entry creation from the date picker when no companion file is connected
    Given no companion file is connected
    When I change the date to a day with no existing entry
    Then the app blocks creating the new entry
    And the date reverts to the current entry
