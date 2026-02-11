Feature: Symptom configuration driven rendering
  Render symptom controls from unified symptom configuration.

  @confirmed
  @SCFG-001
  Scenario: Symptom configuration is loaded from external file
    Given symptoms.json is available
    When the app initializes
    Then symptom options are loaded from the external configuration

  @assumed
  @SCFG-002
  Scenario: Checkbox and slider symptom types render from config
    Given a symptom definition declares an input type
    When symptom fields are rendered
    Then checkbox symptoms render as checkboxes with conditional fields when configured
    And slider symptoms render as range controls

  @confirmed
  @SCFG-003
  Scenario: Missing or invalid config falls back to defaults
    Given symptoms.json cannot be loaded
    When the app initializes
    Then default symptom options are applied
