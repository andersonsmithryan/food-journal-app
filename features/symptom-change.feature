Feature: Post-meal symptom change
  Track whether symptoms worsened after a meal.

  @SYMP-001
  Scenario: Selecting "no" hides and clears post-meal symptom fields
    Given I am logging a meal
    When I set "Did your symptoms get worse?" to "No"
    Then post-meal symptom sliders are cleared and hidden
    And symptom time and approximate fields are cleared and hidden

  @SYMP-002
  Scenario: Selecting "yes" shows post-meal symptoms and copies baseline values
    Given I am logging a meal
    When I set "Did your symptoms get worse?" to "Yes"
    Then post-meal symptom fields are shown
    And baseline symptom values are copied into post-meal fields
