# Jira Integration Readiness for Agent Planning Sync

## Objective
Prepare Jira and repository workflow so plan updates can be synchronized reliably between chat-native planning and Jira work tracking.

## Stage 1: Jira API Access and Permissions
- Confirm Jira Cloud base URL and project keys in scope.
- Create integration credentials (API token or OAuth app).
- Verify permission scopes for:
  - create/update issues
  - transition issue status
  - add comments
  - read/write issue links
- Decide audit requirements (who performed sync actions, logging retention).

### Subtasks
- [ ] Document Jira base URL(s) and in-scope project key(s).
- [ ] Provision integration credentials in a secure secret store.
- [ ] Validate create/update/transition/comment/link permissions with a test issue.
- [ ] Define and document audit log ownership and retention period.

## Stage 2: Mapping Contract (Plan Model -> Jira Model)
- Define how planning hierarchy maps to Jira issue types:
  - goal/objective/key result/initiative/project/epic/story/scenario
- Define required fields per issue type:
  - summary, description, labels, assignee, sprint, component
- Define parent/child model and issue-link conventions.
- Define naming and ID conventions to keep references stable.

### Subtasks
- [ ] Approve hierarchy mapping table (plan layer -> Jira issue type).
- [ ] Define required field templates per issue type.
- [ ] Define parent/child and issue-link policy (`blocks`, `relates to`, etc.).
- [ ] Define canonical ID + naming convention for cross-references.

## Stage 3: Sync Mode and Source-of-Truth Rules
- Choose sync direction:
  - one-way publish (plan -> Jira)
  - two-way reconcile (plan <-> Jira)
- Define source-of-truth policy (repo docs vs Jira) per artifact type.
- Define conflict-resolution policy (including timestamp and manual override process).
- Define failure behavior and retry/rollback rules.

### Subtasks
- [ ] Decide one-way vs two-way sync mode for phase 1.
- [ ] Approve source-of-truth policy by artifact type (plan text, status, links, owners).
- [ ] Approve conflict-resolution procedure and manual override path.
- [ ] Define retry and rollback behavior for failed sync runs.

## Stage 4: Execution Surface and Operational Controls
- Decide execution surface for sync actions:
  - direct tool integration
  - repository script/CI job
  - middleware service
- Define validation checks before sync (schema validation, required-field checks).
- Define CI/automation hooks and observability (alerts, failed-sync dashboard).
- Define rollout plan:
  - sandbox project pilot
  - production rollout
  - owner and support runbook.

### Subtasks
- [ ] Select execution surface (tool-native, script+CI, or middleware).
- [ ] Implement and test pre-sync validators.
- [ ] Set up CI schedule/hooks and failure alerting.
- [ ] Run sandbox pilot and capture lessons learned.
- [ ] Approve production rollout plan and support runbook.

## Readiness Exit Criteria
- All four stages are documented with approved owners.
- Pilot sync succeeds end-to-end in a non-production Jira project.
- Source-of-truth and conflict policy are approved by team.
- Operating runbook exists for failures and credential rotation.
