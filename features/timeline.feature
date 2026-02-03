Feature: Symptom timeline rows
  Track symptom events and onsets relative to meals.

  @assumed
  @TL-001
  Scenario: Adding a timeline row creates a symptom event
    Given I am logging a meal
    When I add a timeline symptom row
    Then a new symptom event row appears

  @assumed
  @TL-002
  Scenario: Updating meal time recalculates timeline onsets
    Given a meal has timeline symptom rows
    When I update the meal time
    Then the timeline onset values update
