# Sprint 01 Backlog V2

## Schedule

- Planned start: 2026-06-15
- Planned end: 2026-06-26
- Goal: deliver login, current state, and zero-record history as one secure flow.

| ID | Owner | Task | Estimate | Dependency |
|---|---|---|---|---|
| S1-BE-01 | Backend | SMS provider port and local fake adapter | 1d | S0-02 |
| S1-BE-02 | Backend | Login, refresh rotation, logout | 2d | S1-BE-01 |
| S1-BE-03 | Backend | Current-state read and change APIs | 1d | S1-BE-02 |
| S1-BE-04 | Backend | Record create, list, detail APIs | 2d | S1-BE-02 |
| S1-MO-01 | Mobile | Login states and secure token storage | 2d | S1-BE-02 |
| S1-MO-02 | Mobile | Home state screen | 1d | S1-BE-03 |
| S1-MO-03 | Mobile | Zero-record create and timeline | 2d | S1-BE-04 |
| S1-QA-01 | Full Stack | Ownership, auth, migration, and flow tests | 2d | all |

## Acceptance Criteria

- A new user can request a local development code and log in.
- Access-token expiry refreshes once without losing the active screen.
- A user can read and change only their own state.
- A user can create and list only their own records.
- Repeated save taps do not create duplicate records.
- AI failure does not block record persistence.
- Backend tests, Flutter analyze/tests, OpenAPI lint, and admin build pass in CI.

## Out of Scope

- Production SMS vendor contract
- Full AI companion implementation
- Memory summarization
- Admin business screens
- BLE and hardware

