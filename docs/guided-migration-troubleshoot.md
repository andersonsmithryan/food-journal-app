# GUIDED_MIGRATION Troubleshoot Record

## Incident
- **Expected behavior:** During GUIDED_MIGRATION assumption outlining, each assumption includes both:
  1) an agile user story, and
  2) an agile scenario in Given/When/Then form.
- **Actual behavior observed:** user story content was present, but agile scenario content was missing in at least one output pass.

## Root Cause Analysis
### Unexpected behavior analysis
- The response format partially satisfied the assumption template but omitted one mandatory field (agile scenario).

### High-probability primary root cause
- **Primary classification:** upstream instructional deficiency in the portable command quality gates.
- Reason: command instructions requested scenario content, but there was no hard validation gate requiring every assumption row to include a non-empty Given/When/Then scenario before completion.

### Deficiency type
- **Type A:** command instruction/quality-gate deficiency.
- (Not primarily a canonical workflow deficiency.)

## Upstream Patch Proposal (Primary)
### Patch 1 — Add a completion validation gate to GUIDED_MIGRATION
Add a mandatory output validation gate before completion:
1. For every assumption row, verify non-empty fields for:
   - plain English description,
   - practical example,
   - agile user story,
   - agile scenario using Given/When/Then,
   - required next step,
   - confidence.
2. If any field is missing, return a **partial-complete** status and auto-regenerate only missing fields.
3. Prevent task closure until validation passes.

### Patch 2 — Add explicit schema for assumption rows
Require a strict row schema:
- `ID`
- `Assumption`
- `Plain English description`
- `Practical example`
- `Agile user story`
- `Agile scenario (Given/When/Then)`
- `Required next step (Confirm/Input/Other)`
- `Confidence (Low/Moderate/High)`

## Downstream Reinforcement Patch (Secondary)
- Keep the migration inventory "Task in progress" section in table format with explicit `Agile scenario (Given / When / Then)` column so missing scenario entries are visually obvious during review.

## Verification Method
- Verify that each assumption line in the active "Task in progress" table includes both a user story and a Given/When/Then scenario.
- Reject completion if any assumption row misses the scenario field.
