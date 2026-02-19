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
| Primary module (initial) | Feature tag | Feature files | Status |
| --- | --- | --- | --- |
| Meals | `@feature:EntrySelector` | `features/entry-selector.feature` | Confirmed |
| Symptoms | `@feature:BaselineSymptoms` | `features/baseline.feature` | Confirmed |
| Meals | `@feature:MealLogging` | `features/meal-logging.feature` | Confirmed |
| Meals | `@feature:IngredientType` | `features/ingredient-type.feature` | Confirmed |
| Symptoms | `@feature:SymptomChange` | `features/symptom-change.feature` | Confirmed |
| Symptoms | `@feature:SymptomConfig` | `features/symptom-config.feature` | Confirmed |
| Symptoms | `@feature:Timeline` | `features/timeline.feature` | Confirmed |
| Meals | `@feature:Macros` | `features/macros.feature` | Confirmed |
| Meals | `@feature:Persistence` | `features/persistence.feature` | Confirmed |
| Meals | `@feature:CompanionFile` | `features/companion-file.feature` | Confirmed |

## Mapping Definition (What is mapped from/to)
- **From:** each Gherkin feature file in `features/*.feature`.
- **To:**
  1) a primary migration module (`Meals` or `Symptoms`), and
  2) a feature tag (`@feature:*`) for finer-grained tracking.
- Purpose: planning ownership and migration sequencing, not renaming feature files.

## Tagging Scheme Proposal (Two-Level Split)
Use two tags per scenario to capture both module and feature.

**Module tags**
- `@module:Meals`
- `@module:Symptoms`

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

## Current-State vs Future-State Reconciliation (Required)
- Planning record can live in chat while drafting, but confirmed decisions should be copied into repo docs to preserve continuity.
- Treat these documents as a capture of **current app behavior** first (baseline for parity).
- Define desired **future architecture** as a separate pass, then reconcile each feature as Keep / Modify / Deprecate.
- Initial known future-state assumptions from review:
  - Preferred first-step future-state continuity path: iCloud sync (pending technical constraints and schema decisions).
  - `EntrySelector` and `Persistence/CompanionFile` are currently shared concerns.
  - Companion-file sync may be deprecated in future architecture.
  - Timeline rows may be deprecated in future architecture.

## Component Ownership (Initial Decision)
- Symptom controls (checkbox/slider/time inputs) are **module-local to Symptoms**.
- Promote to shared `UI/Components` only if another module has a real implementation dependency.

## Module Phases (Inferred) + Parity Gate Examples
**Module phases (initial):**
- **Meals module phase:** entry selection, meal logging, ingredient type, macros, persistence + companion file flow.
- **Symptoms module phase:** baseline symptoms, symptom change, symptom config, timeline.

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

### Boundary Rule Scope and Confidence
- These boundary rules are **target-state SwiftUI architecture rules**, not a literal description of the current single-file web implementation.
- Current-state web code uses one-page JavaScript/DOM mutation patterns and does not enforce Swift module boundaries directly.
- Confidence: high for migration guardrails, but final approval should be based on team architecture decisions.

### Current-State Validation Results (Boundary Rules)
Boundary rules below were validated against the **current** web codebase shape (single `index.html` + DOM/event/persistence coupling):

| Rule | Current-state accurate? | Current-state assessment status |
| --- | --- | --- |
| Hard rule: feature views must not call persistence services directly | No (no feature-module separation exists in current app) | Confirmed: not accurate for current state |
| Hard rule: Meals/Symptoms feature modules must not import each other directly | No (module boundaries do not exist yet) | Confirmed: not accurate for current state |
| Hard rule: models must not import features/persistence/UI | No (model/module import graph does not exist yet) | Confirmed: not accurate for current state |
| Hard rule: violating PRs are blocked on dependency direction | No (no such automated boundary gate is currently implemented) | Confirmed: not accurate for current state |
| Candidate: `Stores/*` must not leak persistence DTOs to `Features/*` | No (stores/features layers do not exist in current app) | Confirmed: not accurate for current state |
| Candidate: `UI/Components/*` must not mutate persistence state directly | No (shared SwiftUI component layer does not exist yet) | Confirmed: not accurate for current state |
| Candidate: `Import/*` must not write directly to UI state | No (separate import layer does not exist yet) | Confirmed: not accurate for current state |
| Candidate: test boundaries should mirror module boundaries | No (module-aligned Swift test targets do not exist yet) | Confirmed: not accurate for current state |

Notes:
- Current web implementation is not module-structured, so these rules cannot be literally true today.
- These remain migration guardrails to confirm for SwiftUI future-state architecture.

### Hard "Must Not" Rules (Migration Gate)
- SwiftUI view files under `Features/*` **must not** import or call concrete persistence services (for example `JournalPersistenceService`, `CompanionFileService`).
- `Features/Meals/*` **must not** import code from `Features/Symptoms/*` directly (and vice versa); shared behavior must be lifted into `Stores/*` or `UI/Components/*`.
- `Models/*` **must not** import from `Features/*`, `Persistence/*`, or `UI/*`.
- PRs that violate these rules are blocked until dependency direction is corrected.

### Enforcement Artifacts
- **PR checklist (project-specific):** a short required checklist in every migration PR description (for example: "No direct persistence calls from views", "No cross-feature imports", "Parity gate notes attached").
- **Lint rule (project-specific):** automated import/path checks run in CI to catch forbidden dependencies before merge.

### Common Term Definitions
- **PR checklist (general):** a repeatable list of verification items reviewers and authors must confirm before merge.
- **Lint rule (general):** a static analysis rule that automatically flags code style or architecture violations.

### Additional Candidate Boundary Rules (Assessed for Current-State Accuracy)
- `Stores/*` should expose intent-based actions and **must not** leak persistence DTOs directly to `Features/*`.
- `UI/Components/*` should remain presentation-focused and **must not** mutate persistence state directly.
- `Import/*` **must not** write directly to UI state; it should return normalized models for store actions.
- Test target boundaries should mirror module boundaries (feature tests should avoid importing concrete persistence services).

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
