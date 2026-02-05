# SwiftUI Migration Guide (Plan & Operating Model)

## 1) Purpose
This guide defines **how we conduct the SwiftUI migration prep** (pattern inventory, risk analysis, and Gherkin backfill). It is the **single source of truth for process and methodology**.

## 2) Scope & Source of Truth
- **Authoritative state:** Current working tree in this repo.
- **Deliverables:**
  1) **Migration Guide** (this document)
  2) **Migration Inventory** (`docs/swiftui-migration-inventory.md`)

## 3) Document Structure (Two-Doc Model)
- **Migration Guide (this doc):** Plan, stages, rules, and operating model.
- **Migration Inventory:** The evolving, raw mapping of web patterns → SwiftUI equivalents.

## 4) Status Tags
All inferred or uncertain items **must be explicitly marked**:
- `@assumed` — inferred intent, not yet confirmed.
- `@needs-confirmation` — ambiguous or conflicting requirements.
- `@deprecated` — superseded or retired requirement.

## 5) Gherkin Backfill Plan (Execution Rules)
**Objective:** Backdate Gherkins to reflect the current app snapshot.
**Method:**
1) Inventory existing app behaviors.
2) Draft Gherkins for each behavior.
3) Mark inferred items as `@assumed`.
4) Review with stakeholder to confirm/resolve.
5) Promote confirmed items and adjust or deprecate as needed.

**Classification rules:**
- If a scenario’s intent is unclear or overlaps a newer scenario, tag it `@needs-confirmation`.
- If a scenario is superseded, keep it but tag it `@deprecated`.
- Prefer tags over deletion to preserve audit history.

**Current status:** Initial backfill completed with `@assumed` tags for inferred scenarios.

## 6) SwiftUI Pattern Inventory Output Format
The inventory document uses a consistent table:

| ID | Location | Web Pattern | Description | SwiftUI Equivalent | Refactor Strategy | Risk | Notes |
|----|----------|-------------|-------------|--------------------|-------------------|------|------|

## 7) Phased Refactor Plan
1) **State Model Extraction**
   - Enumerate all UI state.
   - Define canonical data structures.

2) **View Decomposition**
   - Map DOM templates to SwiftUI views.

3) **Event Migration**
   - Replace delegated DOM events with view-local actions.

4) **Persistence & Sync**
   - Replace localStorage / file handle patterns with SwiftUI-appropriate data layer.

## 8) Failure Modes + Mitigations
| Failure Mode | Impact | Mitigation |
|-------------|--------|-----------|
| Hidden implicit DOM state | Silent bugs | Audit all DOM side-effects |
| Dynamic element IDs not mapped | UI breakage | Use stable IDs in model |
| Long imperative handlers | Unclear flow | Convert to state transitions |
| Ambiguous/deprecated requirements | Drift | Use `@needs-confirmation` and `@deprecated` |

## 9) Update Rules
- **Guide updates are intentional and infrequent.**
- **Inventory updates are frequent and ongoing.**
- Deprecated scenarios are **kept** but tagged.

## 10) Open Items (Pending)
- Generator tool selection and ID map format. (Resolved below.)

## 11) Gherkin Generator & ID Mapping (Adopted)
- **Generator mode:** In-session updates to `.feature` files stored in repo.
- **Config file:** `features/feature-config.yml`
- **ID map:** `features/feature-id-map.json`
- **ID format:** `<PREFIX>-###` (stable per feature file).
- **Rule:** If a scenario has a matching ID in the map, reuse it; otherwise generate the next available ID for that feature.

## 12) Gherkin Automation & Hygiene (Adopted)
- **Invocation:** `make gherkin-sync` runs `scripts/gherkin_id_sync.py`.
- **When to run:** Always run before committing when Gherkin files change.
- **Rationale:** Stable IDs prevent churn in scenario references, and a synchronized ID map keeps scenario identity consistent across edits.
- **Hygiene rules enforced by the script:**
  - Duplicate scenario titles fail the sync with a non-zero exit code.
  - Deprecated scenarios are reported for review (kept for audit history).
