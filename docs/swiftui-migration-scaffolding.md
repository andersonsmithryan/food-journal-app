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

## Module Boundary Enforcement (One-App Approach)

### Boundary Rules
- `Features/*` may depend on `Models`, `Stores`, and shared `UI`, but not directly on persistence implementation details.
- `Persistence/*` and `Import/*` may depend on `Models`, but not on feature views.
- `Models/*` has no dependency on `Features/*` or `UI/*`.
- Cross-feature calls go through `JournalStore` actions, not direct feature-to-feature imports.

### Guardrails
- Keep each feature folder self-contained: view(s), local view model(s), feature-level tests.
- Use protocol abstractions (`JournalPersistence`, `CompanionSyncing`) in `Stores` to prevent tight coupling.
- Require parity-gate checks before merging migrations that touch multiple feature modules.
- Add lint/review rule: no persistence service usage directly in SwiftUI view files.

### Failure-Mode Controls
- **Module coupling:** enforce dependency direction in code review and architecture notes.
- **Codebase growth:** maintain feature folders + protocol boundaries + small view models.
- **State leakage:** all mutation routes through store actions with typed models.

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
