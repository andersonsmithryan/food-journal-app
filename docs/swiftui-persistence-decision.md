# SwiftUI Persistence Decision Memo

## Goal
Choose a durable persistence approach that supports:
- Local draft behavior
- Companion file sync behavior
- Import/export compatibility with existing JSON schema

## Current Web Behavior (Reference)
- Local state persisted to `localStorage`
- Companion file access via File System Access API
- Handle persistence via indexedDB
- Manual import fallback path

## Target SwiftUI Architecture

### Recommended Layers
1. `JournalStore` (ObservableObject)
   - In-memory source of truth for active log/entry
2. `JournalPersistenceService`
   - Read/write JSON to app sandbox and user-selected file URL
3. `JournalImportService`
   - Import + normalize external JSON payloads
4. `CompanionFileService`
   - Companion file permissions/bookmarks + save coordination

### Recommended Storage Choices
- **Primary app storage:** app sandbox JSON file
- **Companion file link:** security-scoped bookmark (when platform requires)
- **Import fallback:** explicit import flow that merges/replaces log data

## Decision
Adopt a dual-path model:
- Always maintain an app-local persisted log.
- If companion file is connected, mirror updates to companion file on successful save.

## Error Handling Rules
- Companion write failure does not discard local save.
- Companion permission loss surfaces warning state and degrades to local-only mode.
- Invalid imports fail safely with no partial writes.

## Acceptance Criteria
- Save updates local persistence every time.
- Save updates companion file when connected and permitted.
- Import normalizes entries and preserves compatibility defaults.
- User can recover from permission loss without data loss.
