# Release v1.1.0 Local Verification Report

Date: 2026-06-20

## Scope

This verification covers the release candidate after Sprint 02 and Sprint 03
were merged into `main`.

Validated areas:

- Authentication
- Zero record creation and browsing
- AI companion fallback response
- Growth summary
- State pattern summary
- Memory list API
- Backend PostgreSQL/Flyway startup
- Mobile, admin, and OpenAPI static gates

## Automated Gates

Commands run locally:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew test

cd ../mobile
flutter analyze
flutter test

cd ../admin
npm run build

cd ..
npx --yes @redocly/cli lint docs/04_API/OpenAPI_V1.yaml
git diff --check
```

Results:

- Backend test suite: passed
- Flutter analyze: passed
- Flutter widget tests: passed
- Admin build: passed
- OpenAPI lint: passed
- Diff whitespace check: passed

## Runtime Verification

Local infrastructure:

- PostgreSQL 16 via Docker Compose
- Redis 7 via Docker Compose
- Backend `bootRun` connected to local PostgreSQL and Redis

Runtime checks:

- `GET /api/v1/system/health`: passed, returned `UP`
- `POST /api/v1/auth/codes`: passed, returned `202`
- `POST /api/v1/auth/login`: passed, returned access and refresh tokens
- `GET /api/v1/state/current`: passed
- `POST /api/v1/records`: passed, created a record with `FOCUS` state
- `POST /api/v1/companion/messages`: passed, returned fallback companion reply
- `GET /api/v1/growth/summary`: passed
- `GET /api/v1/growth/state-pattern`: passed
- `GET /api/v1/records`: passed
- `GET /api/v1/records/{recordId}`: passed
- `GET /api/v1/memory`: passed, returned an empty page for the verification user

## Release-Blocking Finding Fixed

During runtime verification, backend startup initially failed against the real
PostgreSQL schema:

- `memory_entries.importance` is defined as `SMALLINT` in Flyway migration V1
- `MemoryEntryEntity.importance` was mapped as Java `int`
- Hibernate schema validation expected `INTEGER` and rejected the existing
  PostgreSQL column

Fix applied:

- Changed `MemoryEntryEntity.importance` from `int` to `short`
- Updated memory controller tests to pass explicit `short` values

The fix keeps the existing Flyway migration and production schema unchanged.

## Notes

- AI provider credentials were intentionally left empty for local validation.
  The fallback companion response was verified and record persistence remained
  unaffected.
- The state pattern endpoint returned no samples for the verification user
  because no state history was created in this smoke test. The empty-state
  response is valid.
- Memory list returned an empty page because the verification user had no
  memory entries. The API response shape and authentication path were verified.

## Decision

v1.1.0 local verification passed after the schema mapping fix.

The release candidate is ready for version bump, commit, tag, and release
packaging after final review of the local code changes.
