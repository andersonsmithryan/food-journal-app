Feature: Entry selection
  Manage switching entries by date or selector.

  @confirmed
  @ENTR-001
  Scenario: Selecting an existing entry loads its data
    Given multiple entries exist
    When I select a different entry from the entry selector
    Then the selected entry is loaded

  @confirmed
  @ENTR-002
  Scenario: Changing the date creates or loads an entry
    Given I am viewing the journal
    When I change the date picker to another day
    Then the entry for that date is loaded or created
