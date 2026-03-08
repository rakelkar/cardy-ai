# Garden Grid (Phase 1 MVP)

Garden Grid is an iPhone-first, grid-first recursive task and memory app that combines contextual node dashboards with manager/analyst chat tools.

## Architecture

- **UI**: SwiftUI, NavigationStack + TabView
- **State pattern**: MVVM-ish feature views + `AppEnvironment` service composition
- **Persistence**: SwiftData (`@Model` entities)
- **Concurrency**: async/await for AI and reminder integration points
- **Dependency boundaries**: protocol-first repositories/services in `Domain/`

## Primary Concepts

- **Space**: top-level domain (e.g., Garden)
- **Node**: recursive task/memory unit with child nodes
- **ChatThread**: manager vs analyst contextual chat
- **ApprovalBundle**: bulk permissions for recursive operations
- **MemoryEntry**: immutable-ish timeline records for local audit history
- **CaptureItem**: photo/note capture pipeline with intent metadata

## What is mocked in Phase 1

- AI orchestration uses deterministic keyword handling in `MockAIOrchestratorService`.
- Capture analysis returns mock summaries.
- Recursive request escalation generates local `ApprovalBundle` objects.

## Build Order Mapping

Implemented in requested order:
1. Domain models + enums
2. SwiftData persistence
3. Repositories
4. Seed data
5. Tab shell + navigation
6. Spaces grid
7. Node detail
8. Child CRUD
9. Chat screens
10. Mock AI orchestration
11. Capture flow
12. Memory screens
13. Approvals
14. Reminders
15. Search
16. Tests
17. README polish

## Extend to real agent backend

1. Add concrete API-backed implementation of `AIOrchestratorService`.
2. Keep current chat/repository interfaces stable.
3. Move intent parsing from mock service to backend tool orchestration.
4. Preserve `ApprovalBundle` semantics so UX stays bulk-approval-first.
5. Add sync layer without changing feature view contracts.

## Project Layout

- `App/` app entry + environment wiring
- `Features/` feature-first UI screens
- `Domain/` enums/models/protocol boundaries
- `Data/` SwiftData stack + repository/service implementations + sample seed
- `DesignSystem/` reusable components/theme
- `Tests/Unit` and `Tests/UI`

