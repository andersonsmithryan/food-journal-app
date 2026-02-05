Feature: Ingredient type behavior
  Control ingredient detail behavior by selected ingredient type.

  @assumed
  @INGR-001
  Scenario: Single ingredient hides component and packaged detail inputs
    Given I am logging an ingredient
    When ingredient type is "Single Ingredient"
    Then component-specific fields are hidden
    And packaged sub-ingredient detail fields are hidden

  @assumed
  @INGR-002
  Scenario: Prepared recipe enables component workflow
    Given I am logging an ingredient
    When ingredient type is "Prepared Recipe"
    Then component-specific fields are visible
    And component values are editable

  @assumed
  @INGR-003
  Scenario: Packaged food enables sub-ingredient details
    Given I am logging an ingredient
    When ingredient type is "Packaged Food"
    Then sub-ingredient detail fields are visible
    And sub-ingredient values are editable
