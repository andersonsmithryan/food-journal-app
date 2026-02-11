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

## Feature → Module Mapping (Gherkin Files)
| Module | Feature files |
| --- | --- |
| EntrySelector | `features/entry-selector.feature` |
| Baseline | `features/baseline.feature` |
| Meals | `features/meal-logging.feature`, `features/ingredient-type.feature` |
| Symptoms | `features/symptom-change.feature`, `features/symptom-config.feature` |
| Timeline | `features/timeline.feature` |
| Macros | `features/macros.feature` |
| Persistence | `features/persistence.feature`, `features/companion-file.feature` |

## Tagging Scheme Proposal (Two-Level Split)
Use two tags per scenario to capture both module and feature.

**Module tags**
- `@module:EntrySelector`
- `@module:Baseline`
- `@module:Meals`
- `@module:Symptoms`
- `@module:Timeline`
- `@module:Macros`
- `@module:Persistence`

**Feature tags**
- `@feature:BaselineSymptoms`
- `@feature:MealLogging`
- `@feature:IngredientType`
- `@feature:SymptomChange`
- `@feature:SymptomConfig`
- `@feature:Timeline`
- `@feature:Macros`
- `@feature:EntrySelector`
- `@feature:Persistence`
- `@feature:CompanionFile`

**Example**
```
@module:Symptoms
@feature:BaselineSymptoms
Scenario: Baseline symptoms are prefilled for a new entry
```

## Module Phase Definition + Parity Gate Example
**Module phase:** the migration slice that completes a single module end-to-end (model updates, store actions, SwiftUI views, and persistence hooks if needed).

**Parity gates (example for Symptoms module):**
- `@module:Symptoms` scenarios are either `@confirmed` or explicitly rejected.
- Baseline symptoms (pre-meal) render and save correctly in SwiftUI.
- Post-meal symptom change inputs match current behavior.
- Symptoms load from `symptoms.json` and persist through save/load cycles.

**Parity checklist example (Symptoms module):**
- [ ] Baseline symptom controls render according to config.
- [ ] Symptom change workflow matches web behavior (time, approx, selection).
- [ ] Save → reload preserves symptom values.
- [ ] Timeline symptom rows still update when meal times change.

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
