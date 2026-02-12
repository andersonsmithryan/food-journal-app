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
- [ ] Review module → feature mapping table (mark inferred entries confirmed)
- [ ] Finalize module boundary rules and review guardrails
- [ ] Publish module → feature file mapping table
- [ ] Define module phases + parity gates per module
- [ ] Define parity checklist per module phase
- [ ] Capture and sign off current-state behavior baseline (before architecture changes)
- [ ] Map components/features to future-state architecture (Keep / Modify / Deprecate)

**Status notes:** Core inventory complete; additional readiness tasks added for Gherkin confirmation and module planning.

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
