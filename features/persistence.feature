Feature: Persistence and companion file sync
  Store entries locally and sync to a companion file when connected.

  @assumed
  @PERS-001
  Scenario: Saving an entry writes to local storage
    Given I have edited an entry
    When I save the draft
    Then the entry is saved to local storage

  @assumed
  @PERS-002
  Scenario: Saving an entry updates the companion file when connected
    Given a companion file is connected
    And I have edited an entry
    When I save the draft
    Then the companion file is updated

  @assumed
  @PERS-003
  Scenario: Importing a companion file loads entries into the journal
    Given I import a valid companion file
    When the import completes
    Then the entries from the file are loaded
