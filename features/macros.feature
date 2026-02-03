Feature: Macro nutrient tracking
  Capture macro totals after finishing a meal.

  @assumed
  @MACR-001
  Scenario: Macro fields are shown after finishing a meal
    Given I finish logging a meal
    When the meal is marked finished
    Then macro nutrient inputs are shown
