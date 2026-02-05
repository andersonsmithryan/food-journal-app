# SwiftUI Migration Scaffolding Plan

## Objective
Define the initial project/module layout and migration sequencing before implementing SwiftUI screens.

## Proposed Structure

### Domain
- `Models/`
  - `JournalLog.swift`
  - `JournalEntry.swift`
  - `Meal.swift`
  - `Component.swift`
  - `Ingredient.swift`
  - `SymptomState.swift`

### Data
- `Stores/JournalStore.swift`
- `Persistence/JournalPersistenceService.swift`
- `Persistence/CompanionFileService.swift`
- `Import/JournalImportService.swift`

### Features
- `Features/EntrySelector/`
- `Features/Baseline/`
- `Features/Meals/`
- `Features/Symptoms/`
- `Features/Timeline/`
- `Features/Macros/`

### Shared UI
- `UI/Components/`
- `UI/Theme/`

## Migration Order
1. Domain models + decoding compatibility
2. Persistence services + store
3. Entry selector + baseline screen
4. Meal card shell + component/ingredient lists
5. Symptom sections (baseline + post-meal)
6. Timeline + macros
7. Companion file connection UX

## Parity Gates
Before moving to next phase:
- Matching Gherkin scenarios exist/updated
- Existing behavior parity manually verified
- Data round-trip (load/edit/save/reload) verified

## Non-Goals (Early Phase)
- UI polish parity
- New product features
- Platform-specific optimizations
