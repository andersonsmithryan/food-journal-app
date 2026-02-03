# SwiftUI Migration Inventory (Pattern Map)

## 1) Executive Summary
- **Scope of audit:** `index.html` (single-page app), `symptoms.json` (symptom config).
- **Complexity score:** Medium (single file, but heavy DOM mutation + templates).
- **Highest-risk areas:** DOM mutation + template cloning, event delegation, persistence coupling.

## 2) Inventory Table (Core Artifact)
| ID | Location | Web Pattern | Description | SwiftUI Equivalent | Refactor Strategy | Risk | Notes |
|----|----------|-------------|-------------|--------------------|-------------------|------|------|
| DOM-01 | index.html → `setBaselineLocked`, `updateSymptomSectionVisibility` | DOM Queries | Uses `querySelector`/`querySelectorAll` to enable/disable and hide baseline & symptom fields. | `@State` + `disabled()` + conditional view modifiers | Introduce `BaselineState` and derived visibility bindings. | Med | Many conditional branches rely on DOM state. |
| TMP-01 | index.html → `<template>` blocks (`meal`, `ingredient`, `timeline`) | Template Cloning | `cloneNode(true)` and manual wiring for repeated UI sections. | `ForEach` + reusable `View` structs | Define view models (`Meal`, `Ingredient`, `TimelineRow`) and render via `ForEach`. | Med | Large templates with imperative wiring. |
| EVT-01 | index.html → `document.addEventListener('click'/'input'/'change')` | Event Delegation | Global listeners route by class name. | View-local handlers (`Button`, `.onChange`) | Move handlers into view components with explicit bindings. | Low | Straightforward mapping. |
| SHW-01 | index.html → `classList.toggle('hidden')` | Imperative Show/Hide | Toggling DOM classes to show/hide sections. | Conditional views (`if`/`Group`) | Use state to derive visibility instead of DOM toggles. | Med | Visibility logic spread across helpers. |
| PERS-01 | index.html → `localStorage` + file handles | Persistence Coupling | Saves to localStorage and companion file handles. | `ObservableObject` + persistence service | Isolate persistence layer and inject into views. | Med | Mix of local + file sync rules. |

## 3) Pattern Categories
### DOM Queries
- **Definition:** Direct DOM lookups for state or UI manipulation (`querySelector`, `querySelectorAll`).
- **Instances:** Baseline locking, symptom toggles, meal cards, ingredient fields.
- **SwiftUI mapping:** Replace with state-driven view updates.
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

## 4) Refactor Plan (Phased)
### Phase 1: State Model Extraction
- Enumerate all UI state into view models (`Entry`, `Meal`, `Ingredient`, `SymptomState`).

### Phase 2: View Decomposition
- Convert templates into SwiftUI views with `ForEach` and bindings.

### Phase 3: Event Migration
- Replace delegated events with view-local actions and `.onChange` handlers.

### Phase 4: Persistence & Sync
- Isolate persistence into a data layer and sync service.

## 5) Migration Readiness Checklist
- [ ] All state variables enumerated
- [ ] All template clones mapped to views
- [ ] All DOM mutation sites replaced by state-driven UI
- [ ] Persistence & file sync strategy mapped

## 6) Failure Modes + Mitigation
| Failure Mode | Impact | Mitigation |
|-------------|--------|-----------|
| Hidden implicit DOM state | Silent bugs | Capture state in view models and derive UI from state. |
| Event routing drift | Missed actions | Replace delegated events with explicit handlers per view. |
| Mixed persistence logic | Data inconsistency | Centralize storage in a persistence service. |
