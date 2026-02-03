Feature: Meal logging
  Manage meal creation and ingredient details.

  @MEAL-001
  Scenario: Add meal is disabled until baseline is complete
    Given the baseline has not been finished
    When I view the meals section
    Then the add meal controls are disabled
