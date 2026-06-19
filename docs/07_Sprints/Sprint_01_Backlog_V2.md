# Sprint 01 Backlog V3

## Schedule

- Planned start: 2026-06-15
- Planned end: 2026-06-26
- Goal: deliver login, current state, and zero-record history as one secure flow.

## Product Navigation

Sprint 01 keeps the primary navigation intentionally small:

- Now
- Reset
- Archive

Growth, reflection, expression, export, device link, model settings, and custom
AI model configuration are not primary navigation items in Sprint 01.

## Scope Principle

Sprint 01 builds the data foundation for ZEROON's long-term companion and memory
system. It must not expand into relationship-specific, gift-specific, social,
or hardware-led features.

| ID | Owner | Task | Estimate | Dependency | Status |
|---|---|---|---|---|---|
| S1-BE-01 | Backend | SMS provider port and local fake adapter | 1d | S0-02 | Done |
| S1-BE-02 | Backend | Login, refresh rotation, logout | 2d | S1-BE-01 | Done |
| S1-BE-03 | Backend | Current-state read and change APIs | 1d | S1-BE-02 | Done |
| S1-BE-04 | Backend | Record create, list, detail APIs | 2d | S1-BE-02 | Done |
| S1-MO-01 | Mobile | Login states and secure token storage | 2d | S1-BE-02 | Done |
| S1-MO-02 | Mobile | Home state screen | 1d | S1-BE-03 | Done |
| S1-MO-03 | Mobile | Zero-record create and timeline | 2d | S1-BE-04 | Done |
| S1-QA-01 | Full Stack | Ownership, auth, migration, and flow tests | 2d | all | Done |

## Acceptance Criteria

- A new user can request a local development code and log in.
- Access-token expiry refreshes once without losing the active screen.
- A user can read and change only their own state.
- A user can create and list only their own records.
- Repeated save taps do not create duplicate records.
- AI failure does not block record persistence.
- Backend tests, Flutter analyze/tests, OpenAPI lint, and admin build pass in CI.

## Delivery Status

Sprint 01 MVP implementation is complete for backend and mobile:

- Backend Auth APIs are implemented with local verification code, access token,
  refresh token rotation, and logout.
- Backend State APIs are implemented with user ownership and state history.
- Backend Record APIs are implemented with create, list, detail, ownership
  isolation, and repeated-save protection.
- Mobile login, token storage, Now, Reset, Archive, and record detail are
  implemented.
- Admin business screens remain out of Sprint 01 scope.

## Verification

Validated locally on 2026-06-19:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew test

cd ../mobile
flutter analyze
flutter test

cd ..
git diff --check
```

Results:

- Backend tests: passed.
- Flutter analyze: passed.
- Flutter tests: passed.
- Diff whitespace check: passed.
- OpenAPI lint: passed.
- Admin build: passed.

## Out of Scope

- Production SMS vendor contract
- Full AI companion implementation
- Memory summarization
- User insight profile
- Growth report implementation
- Expression templates
- Card or report export
- Custom AI model settings
- Admin business screens
- BLE and hardware
- Gift mode, confession mode, recipient pages, couple features, social sharing, or public feeds

## Carryover Candidates

These are accepted product directions, but they must be scheduled after the
Sprint 01 main flow is stable:

- Growth summary: can remain as a prototype and API contract until Sprint 03.
- AI reflection: can appear later as cards in Archive or Growth.
- Expression: can later become record templates, not a standalone emotional
  relationship module.
- Export: can later generate memory cards or reports from existing records.
- Device link: remains a future Settings or Device page capability.
