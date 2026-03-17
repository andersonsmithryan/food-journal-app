# SwiftUI Migration Inventory (Pattern Map)

## 1) Executive Summary
- **Scope of audit:** `index.html` (single-page app), `symptoms.json` (symptom config).
- **Complexity score:** Medium (single file, but heavy DOM mutation + templates).
- **Highest-risk areas:** DOM mutation + template cloning, event delegation, persistence coupling.

## 2) Inventory Table (Core Artifact)
| ID | Location | Web Pattern | Description | SwiftUI Equivalent | Refactor Strategy | Risk | Notes |
|----|----------|-------------|-------------|--------------------|-------------------|------|------|
| DOM-01 | index.html → `setBaselineLocked`, `updateSymptomSectionVisibility` | DOM Queries | Uses `querySelector`/`querySelectorAll` to enable/disable and hide baseline & symptom fields. | `@State` + `disabled()` + conditional view modifiers | Introduce `BaselineState` and derived visibility bindings. | Med | Many conditional branches rely on DOM state. |
| DOM-02 | index.html → `collectMeal`, `collectPreMealState` | DOM Queries | Reads form values directly from DOM for serialization. | `@State` + `Codable` models | Bind inputs directly to models rather than querying DOM. | Med | Serialization depends on current DOM. |
| DOM-03 | index.html → `updateNewEntryButtonVisibility` | DOM Queries | Enables/disables buttons based on current log + companion connection. | Derived state + disabled modifier | Make availability a computed state in view model. | Low | Simple derived state. |
| TMP-01 | index.html → `<template>` blocks (`meal`, `ingredient`, `timeline`) | Template Cloning | `cloneNode(true)` and manual wiring for repeated UI sections. | `ForEach` + reusable `View` structs | Define view models (`Meal`, `Ingredient`, `TimelineRow`) and render via `ForEach`. | Med | Large templates with imperative wiring. |
| EVT-01 | index.html → `document.addEventListener('click'/'input'/'change')` | Event Delegation | Global listeners route by class name. | View-local handlers (`Button`, `.onChange`) | Move handlers into view components with explicit bindings. | Low | Straightforward mapping. |
| SHW-01 | index.html → `classList.toggle('hidden')` | Imperative Show/Hide | Toggling DOM classes to show/hide sections. | Conditional views (`if`/`Group`) | Use state to derive visibility instead of DOM toggles. | Med | Visibility logic spread across helpers. |
| STATE-01 | index.html → `dataset.*` flags on cards | DOM Data Attributes | Stores UI state (locked, finished, hidden) on DOM nodes. | `@State` / model flags | Move flags into model state and bind to view. | Med | Multiple flags across meal cards. |
| STATE-02 | index.html → `applySymptomChangeSelection` | State Transitions | Mutates symptom fields, time fields, and hides sections. | Action method on view model | Centralize transition logic in model layer. | Med | Coupled with UI and baseline copy. |
| STATE-03 | index.html → `applyIngredientType` | State Transitions | Changes component mode + ingredient detail visibility. | View model + conditional views | Use ingredient type enum and view logic. | Med | Multiple UI branches. |
| CONF-01 | index.html → `loadSymptomConfig` | External Config | Fetches `symptoms.json` at runtime with fallback defaults. | Bundled config or remote fetch | Provide config via bundled JSON or service. | Low | Add error handling in data layer. |
| CONF-02 | symptoms.json | Data Schema | Symptom options define labels, keys, input types, conditional fields. | SwiftUI model definitions | Convert JSON to `Codable` models. | Low | Stable schema. |
| PERS-01 | index.html → `localStorage` + file handles | Persistence Coupling | Saves to localStorage and companion file handles. | `ObservableObject` + persistence service | Isolate persistence layer and inject into views. | Med | Mix of local + file sync rules. |
| PERS-02 | index.html → `saveLogToFileIfConnected` | File Access | Writes to File System Access API with permissions. | File coordinator / document-based model | Define file I/O layer or document-based storage. | Med | Permissions and errors. |
| PERS-03 | index.html → `importCompanionFile` | Import Flow | Loads JSON into current log without handle. | Import pipeline with validation | Normalize input and store source metadata. | Low | Straightforward parse + normalize. |
| UI-01 | index.html → date picker + entry selector | UI State | Changes entry based on date or select dropdown. | `Picker` + binding to entry ID | Bind selection to entry ID and derived date. | Med | Multiple entry sources. |
| UI-02 | index.html → timeline rows | Dynamic Lists | Adds/removes timeline symptom rows. | `ForEach` + add/remove actions | Use identifiable rows bound to state. | Med | Mixed ordering and time calculation. |
| UI-03 | index.html → macros grid | Conditional Inputs | Shows macro fields based on meal completion. | Conditional view section | Model macro state and show when needed. | Low | Straightforward toggle. |
| VALID-01 | index.html → `isMealReady` | Validation | Requires meal name + prep selection before finishing. | Validation on model | Compute readiness in view model. | Low | Simple rules. |

## 3) Pattern Categories
### DOM Queries
- **Definition:** Direct DOM lookups for state or UI manipulation (`querySelector`, `querySelectorAll`).
- **Instances:** Baseline locking, symptom toggles, entry selector, meal cards, ingredient fields.
- **SwiftUI mapping:** Replace with state-driven view updates and bindings.
- **Risks:** Hidden dependencies in DOM structure.

### Template Cloning
- **Definition:** Cloning HTML templates and attaching event logic.
- **Instances:** Meal cards, ingredient rows, component cards, timeline rows.
- **SwiftUI mapping:** `ForEach` + reusable views backed by data models.
- **Risks:** Large, imperative setup logic per clone.

### Event Delegation
- **Definition:** Global listeners routing events by class selectors.
- **Instances:** `document.addEventListener('click'/'input'/'change')`.
- **SwiftUI mapping:** View-local handlers, bindings, and `.onChange`.
- **Risks:** Low; mostly mechanical migration.

### Imperative Show/Hide Logic
- **Definition:** Directly toggling CSS classes to hide/show elements.
- **Instances:** Symptom sections, macro grids, ingredient details.
- **SwiftUI mapping:** Conditional rendering via state.
- **Risks:** Medium; state is currently implicit in DOM.

### Mutable Shared State / Persistence Coupling
- **Definition:** Local storage + file handle writes intertwined with UI.
- **Instances:** `saveLog`, `saveLogToFileIfConnected`, companion file connect/import.
- **SwiftUI mapping:** Dedicated persistence service / data store.
- **Risks:** Medium; multi-source persistence rules.

### DOM Data Attributes
- **Definition:** UI state stored in `dataset` flags on DOM nodes.
- **Instances:** `dataset.mealFinished`, `dataset.symptomsUnlocked`, `dataset.symptomFieldsHidden`.
- **SwiftUI mapping:** Model flags in state objects.
- **Risks:** Medium; scattered state updates.

### External Config & Schema
- **Definition:** Runtime config fetched from JSON.
- **Instances:** `symptoms.json` + default config fallback.
- **SwiftUI mapping:** Bundled config + `Codable` schema.
- **Risks:** Low; ensure schema stability.

## 4) State Catalog (Enumeration)
### Global / App State
- `currentLog` (loaded log data from local storage / companion file).
- `currentEntryId` (selected entry identifier).
- `dataFileHandle` (File System Access handle for companion file).
- `companionAvailable` (bool indicating companion connection).
- `symptomConfig` (current symptom configuration list).
- `timelineSymptomOptions` (labels used in timeline selectors).
- `preMealKeys` (ordered keys for baseline symptoms).

### Entry State
- `entry.isoDate`, `entry.displayDate`.
- `entry.notesForToday`, `entry.createdAt`, `entry.updatedAt`.
- `entry.preMealState`, `entry.preMealTime`, `entry.preMealApprox`, `entry.preMealLocked`.
- `entry.preMealHeartRateIncrease`, `entry.preMealHeartRateBpm` (legacy compatibility fields).
- `entry.meals[]` (list of meal objects).

### Meal State (per meal card)
- `meal.type`, `meal.timeEaten`, `meal.timeApprox`, `meal.mealName`.
- `meal.portionSize`, `meal.notes`, `meal.reheatedDays`, `meal.finished`.
- `meal.symptomChange`, `meal.symptomTime`, `meal.symptomApprox`.
- `meal.symptoms`, `meal.digestion`, `meal.macros`, `meal.timeline[]`.

### Component / Ingredient State
- `component.name`, `component.quantity`, `component.allergens`, `component.ingredientType`.
- `component.ingredients[]` (sub-ingredient list).
- `ingredient.name`, `ingredient.quantity`, `ingredient.brandSource`, `ingredient.allergens`, `ingredient.subIngredients`.

### UI State (DOM-derived flags)
- `dataset.mealFinished`, `dataset.symptomsUnlocked`, `dataset.symptomFieldsHidden`.
- `dataset.componentMode`, `dataset.ingredientType`.
- `dataset.finished` (component-level add button state).

## 5) Refactor Plan (Phased)
### Phase 1: State Model Extraction
- Enumerate all UI state into view models (`Entry`, `Meal`, `Ingredient`, `SymptomState`).

### Phase 2: View Decomposition
- Convert templates into SwiftUI views with `ForEach` and bindings.

### Phase 3: Event Migration
- Replace delegated events with view-local actions and `.onChange` handlers.

### Phase 4: Persistence & Sync
- Isolate persistence into a data layer and sync service.

## 6) Migration Readiness Checklist
- [x] All state variables enumerated
- [x] All template clones mapped to views
- [x] All DOM mutation sites replaced by state-driven UI
- [x] Persistence & file sync strategy mapped
- [x] Confirm all remaining `@assumed` Gherkin scenarios
- [ ] Add module + feature tagging to Gherkin scenarios
- [x] Review module → feature mapping table (mark inferred entries confirmed)
- [x] Draft module boundary rules and review guardrails
- [x] Confirm/approve module boundary rules and review guardrails
- [ ] Confirm future-state applicability of approved boundary rules
- [x] Publish module → feature file mapping table
- [ ] Configure Jira integration for live sync with agent planning mode
- [ ] Define module phases + parity gates per module
- [ ] Define parity checklist per module phase
- [ ] Capture and sign off current-state behavior baseline (before architecture changes)
- [ ] Map components/features to future-state architecture (Keep / Modify / Deprecate)

**Status notes:** Core inventory complete; additional readiness tasks added for Gherkin confirmation and module planning.

### Boundary Rule Status Tracker (Current vs Future)
| Boundary rule | Current-state confirmation status | Future-state confirmation status |
| --- | --- | --- |
| Feature views must not call persistence services directly | Confirmed: not accurate for current state | Pending confirmation |
| Meals/Symptoms feature modules must not import each other directly | Confirmed: not accurate for current state | Pending confirmation |
| Models must not import features/persistence/UI | Confirmed: not accurate for current state | Pending confirmation |
| PRs violating dependency direction are blocked | Confirmed: not accurate for current state | Pending confirmation |
| `Stores/*` should not leak persistence DTOs to `Features/*` | Confirmed: not accurate for current state | Pending confirmation |
| `UI/Components/*` should not mutate persistence state directly | Confirmed: not accurate for current state | Pending confirmation |
| `Import/*` should not write directly to UI state | Confirmed: not accurate for current state | Pending confirmation |
| Test boundaries should mirror module boundaries | Confirmed: not accurate for current state | Pending confirmation |



### Task in progress
**In Progress:** Confirm future-state applicability of candidate boundary rules.

#### Assumptions inventory (A: documented and pending confirmation)
| ID | Assumption | Plain English description | Practical example | Agile user story | Agile scenario (Given / When / Then) | Required next step | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | Feature views should not call persistence services directly | UI code should trigger store intents, not write files/cloud directly. | `MealsView` triggers `JournalStore.saveDraft()` instead of calling a file/iCloud adapter. | As a developer, I want views to call store actions so that UI logic stays testable and persistence-agnostic. | Given a user taps Save, when the view dispatches save intent, then the store handles persistence via an abstraction without the view calling persistence services. | Confirm | High |
| A2 | Meals and Symptoms modules should not import each other directly | Feature modules should stay independent and share only through approved shared layers. | `Features/Meals` does not import `Features/Symptoms`; shared code lives in shared/store layers. | As a maintainer, I want module boundaries enforced so that changes in one module do not cascade into another. | Given a new Meals capability, when implementation is added, then it must not import Symptoms internals directly. | Confirm | High |
| A3 | Models should remain independent from feature/persistence/UI layers | Core business types should not depend on views or storage implementations. | `Meal` / `Entry` models do not import SwiftUI or persistence modules. | As an architect, I want domain models to stay pure so that they can be reused across UI and storage implementations. | Given domain models are compiled, when dependencies are checked, then no feature/persistence/UI imports appear in model files. | Confirm | High |
| A4 | PR boundary violations should be blocked | Boundary-breaking changes should be prevented at review/CI gates. | A PR fails if it introduces forbidden dependency direction. | As a team lead, I want boundary checks in PRs so that architecture drift is stopped before merge. | Given a PR introduces a forbidden import, when checks run, then merge is blocked until fixed. | Input (choose enforcement mechanism/timing) | Moderate |
| A5 | Stores should not leak persistence DTOs to feature code | Feature code should consume domain/action outputs, not storage payload schemas. | Store maps persistence payload to domain model before returning to views. | As a developer, I want stores to hide persistence details so that storage changes do not break feature code. | Given data is loaded, when feature reads state, then it receives domain/action results rather than persistence payload structs. | Confirm | Moderate |
| A6 | Shared UI components should be presentation-only | Reusable UI should render/bind state without persistence side effects. | `SymptomSliderView` binds values but does not write local/iCloud data directly. | As a UI engineer, I want shared components to be presentation-only so that side effects remain centralized. | Given a shared component interaction, when value changes, then it emits state changes without mutating persistence directly. | Confirm | High |
| A7 | Import flow should normalize data then dispatch store actions | Import path should parse/normalize first, then state mutation happens through store. | Imported JSON is normalized to domain structures before applying to app state. | As a developer, I want import logic normalized before state updates so that malformed data is handled consistently. | Given external data is imported, when validation/normalization completes, then store actions apply updates to state. | Confirm | Moderate |
| A8 | Test boundaries should mirror module boundaries | Test structure should reinforce architecture separation. | Feature tests mock persistence protocols instead of importing concrete adapters. | As a QA/dev engineer, I want tests to align with module boundaries so that layering violations are caught early. | Given a feature test suite, when dependencies are inspected, then it avoids direct concrete persistence imports except explicit integration tests. | Input (depends on test strategy maturity) | Moderate |

#### Assumptions inventory (B: identified by assistant, not yet committed)
| ID | Assumption | Plain English description | Practical example | Agile user story | Agile scenario (Given / When / Then) | Required next step | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| B1 | Persistence abstraction remains valid for iCloud-first direction | A protocol boundary should allow local/iCloud implementations to be swapped. | `JournalPersistence` protocol with local and iCloud adapters. | As a product engineer, I want a protocol-backed persistence layer so that we can evolve storage providers with low feature churn. | Given iCloud-first is selected, when persistence implementation changes, then feature code remains unchanged behind the abstraction. | Confirm | High |
| B2 | Companion-file boundaries are transitional | Companion-specific rules may reduce if future state deprecates companion flow. | Companion import/export remains during transition, then is retired post-iCloud stabilization. | As a migration planner, I want transitional rules flagged so that temporary architecture decisions are intentionally retired. | Given companion flow is deprecated, when future-state mapping is finalized, then companion-specific boundary rules are marked remove/deprecate. | Input (needs deprecation timeline) | Moderate |
| B3 | PR enforcement may begin as soft gate, then CI hard block | Teams may stage governance from checklist review to automated blocking. | Start with PR checklist; add CI lint blocker once module structure settles. | As an engineering manager, I want phased enforcement so that governance adoption does not stall delivery. | Given boundary rules are newly introduced, when rollout starts, then soft gate is used first and upgraded to CI blocking at agreed milestone. | Input (choose rollout milestone) | Moderate |
| B4 | Import-boundary strictness depends on future import UX scope | If import becomes rare/removed, strict import boundaries may be lower priority. | Import tooling kept minimal if app writes directly to cloud-backed store. | As a system designer, I want import controls proportionate to product usage so that complexity stays justified. | Given import is de-scoped in future architecture, when boundary set is finalized, then import-specific rules are relaxed or archived. | Input (confirm future import scope) | Moderate |

#### Next 3–5 steps for this in-progress task
1. User reviews A1–A8 and marks each as Apply / Modify / Reject.
2. User provides input on A4 and A8 plus B1–B4 decision points.
3. Assistant updates boundary tracker future-state status per rule with rationale.
4. Assistant marks checklist task “Confirm future-state applicability of approved boundary rules” complete.
5. Assistant proceeds to the next started item: define module phases + parity gates per module.

### Incomplete Tasks Grouped by Stage

**Started (in progress, prioritize finishing):**
- [x] Draft module boundary rules and review guardrails
- [x] Confirm/approve module boundary rules and review guardrails
- [ ] Confirm future-state applicability of approved boundary rules
- [ ] Define module phases + parity gates per module
- [ ] Define parity checklist per module phase
- [ ] Capture and sign off current-state behavior baseline (before architecture changes)
- [ ] Map components/features to future-state architecture (Keep / Modify / Deprecate)

**Backlog (not started):**
- [ ] Add module + feature tagging to Gherkin scenarios
- [ ] Configure Jira integration for live sync with agent planning mode

## 6.1) Template Clone → SwiftUI View Mapping
- `#meal-template` → `MealCardView` (meal shell, metadata, finish state).
- `#component-template` → `ComponentCardView` (ingredient type + component metadata).
- `#ingredient-template` → `IngredientRowView` (name, quantity, allergens, sub-ingredients).
- `#timeline-row-template` → `TimelineRowView` (symptom timeline entry).

## 6.2) DOM Mutation → State-Driven Mapping
- `classList.toggle('hidden')` → Conditional rendering (`if` / `.hidden()` modifiers).
- `element.disabled = true/false` → `disabled(_:)` modifier from state.
- `element.value = ...` / `element.checked = ...` → Two-way bindings to model state.
- `dataset.*` flags → explicit model fields (`isFinished`, `symptomsUnlocked`, `componentMode`).
- Direct `querySelector` updates → derived state + bindings instead of DOM queries.

## 7) Failure Modes + Mitigation
| Failure Mode | Impact | Mitigation |
|-------------|--------|-----------|
| Hidden implicit DOM state | Silent bugs | Capture state in view models and derive UI from state. |
| Event routing drift | Missed actions | Replace delegated events with explicit handlers per view. |
| Mixed persistence logic | Data inconsistency | Centralize storage in a persistence service. |

## 6.3) Persistence & File Sync Strategy Mapping
- **Local draft storage:** `localStorage` (`loadLog` / `saveLog`) → `AppDataStore` with `@Published` state.
- **Companion file handle storage:** `indexedDB` handle store → document coordinator + persisted bookmark (sandbox-safe).
- **Companion file read/write:** `readLogFromFile` / `writeLogToFile` → `FileDocument` or file coordinator-based service.
- **Manual import:** `importCompanionFile` → import pipeline with validation + normalization.
- **Sync trigger points:** `saveDraft`, `applyDataFileHandle`, auto-connect flow → unified persistence service.
