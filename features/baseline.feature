Feature: Baseline symptoms
  Capture and lock baseline symptoms before meal logging.

  @BASE-001
  Scenario: Finishing baseline locks inputs and hides zero or unchecked symptoms
    Given I have entered baseline symptoms
    When I finish the baseline
    Then baseline inputs are locked
    And baseline symptom fields with zero values or unchecked boxes are hidden
