# Sprint 01 Acceptance Report

Date: 2026-06-19

## Scope

Sprint 01 delivers the first secure ZEROON mobile/backend loop:

- Login with local verification code
- Session persistence and refresh
- Current state read and change
- Zero-record creation
- Archive list
- Record detail

## Completed Deliverables

### Backend

- `POST /api/v1/auth/codes`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `GET /api/v1/state/current`
- `POST /api/v1/state/changes`
- `POST /api/v1/records`
- `GET /api/v1/records`
- `GET /api/v1/records/{recordId}`

Security and ownership:

- Bearer token authentication
- Refresh token rotation
- Logout revocation
- User-owned state access
- User-owned record access
- Cross-user record detail returns not found

### Mobile

- Login screen
- Secure token store
- API client with bearer token injection
- 401 refresh retry
- Now page with current state
- Manual state change
- Reset page for record creation
- Archive page for record list
- Record detail page
- Now / Reset / Archive bottom navigation

## Validation Results

Commands run locally:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew test

cd ../mobile
flutter analyze
flutter test

cd ..
npx --yes @redocly/cli lint docs/04_API/OpenAPI_V1.yaml

cd admin
npm run build

cd ..
git diff --check
```

Results:

- Backend test suite: passed
- Flutter analyze: passed
- Flutter widget tests: passed
- OpenAPI lint: passed
- Admin build: passed
- Diff whitespace check: passed

## End-to-End Verification

Environment:

- Docker Desktop
- PostgreSQL 16 Alpine via `deployment/compose.yaml`
- Redis 7 Alpine via `deployment/compose.yaml`
- Spring Boot backend on `http://localhost:8080`

Command path:

```bash
docker compose --env-file .env.example -f deployment/compose.yaml up -d

cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew bootRun
```

HTTP flow validated:

- `GET /api/v1/system/health` returned `UP`
- `POST /api/v1/auth/codes` returned `202`
- `POST /api/v1/auth/login` returned access and refresh tokens
- `GET /api/v1/state/current` returned `CALM`
- `POST /api/v1/state/changes` changed state to `FOCUS`
- `POST /api/v1/records` created a record
- `GET /api/v1/records` listed the created record
- `GET /api/v1/records/{recordId}` returned record detail
- `POST /api/v1/auth/refresh` rotated refresh token
- `POST /api/v1/auth/logout` returned `204`
- Refresh after logout returned `401`

## Product Guardrails

The implementation intentionally excludes:

- AI companion full implementation
- Memory summarization
- Growth implementation
- Expression templates
- Card or report export
- Custom AI model settings
- Gift mode, confession mode, recipient pages, couple features, social sharing,
  and public feeds
- BLE or hardware-led features

## Remaining Work Before Release Candidate

- Mobile device-specific API base URL checks:
  - iOS simulator: `http://localhost:8080/api/v1`
  - Android emulator: `http://10.0.2.2:8080/api/v1`
  - Physical device: LAN IP of the backend machine.

## Acceptance Decision

Sprint 01 is accepted for mobile/backend MVP implementation.

Release candidate readiness requires the remaining verification items above.
