# Sprint 03 Plan V2

## Sprint Goal

Deliver Growth and Memory enhancement while keeping ZEROON's information
architecture calm and non-social.

Duration:

2 Weeks

---

## Product Navigation

Primary navigation remains:

- Now
- Reset
- Archive

Growth is reached from the Now page and the future My page, not as a required
primary tab in this sprint.

---

## Scope

### Growth

- Companion days
- First record date
- Continuous reset days
- Cached entry count
- Stage observation copy

### Memory

- Archive timeline refinement
- Important memory markers
- Record detail page
- AI observation card attached to visible records

### Reflection

- Recent state pattern summary
- Non-diagnostic self-understanding copy
- User-visible explanation of data sources

---

## Backend Tasks

| ID | Owner | Task | Estimate | Dependency |
|---|---|---|---|---|
| S3-BE-01 | Backend | Growth summary implementation | 1d | Sprint 01 |
| S3-BE-02 | Backend | Timezone-safe continuous reset calculation | 1d | S3-BE-01 |
| S3-BE-03 | Backend | Memory entry list and detail refinement | 1d | Sprint 01 |
| S3-BE-04 | Backend | Recent state pattern summary | 2d | S3-BE-01 |
| S3-BE-05 | Backend | User ownership and deletion tests | 1d | all |

## Mobile Tasks

| ID | Owner | Task | Estimate | Dependency |
|---|---|---|---|---|
| S3-MO-01 | Mobile | Growth page with real data | 2d | S3-BE-01 |
| S3-MO-02 | Mobile | Archive record detail | 1d | S3-BE-03 |
| S3-MO-03 | Mobile | Recent reflection card | 1d | S3-BE-04 |

---

## Acceptance Criteria

- Growth page uses real user-owned data.
- `2025-06-11` through `2026-06-10` calculates as 365 companion days.
- A new user shows clear empty states.
- Broken streaks do not delete history or create negative language.
- Reflection explains its source data and avoids fixed labels such as "you are this kind of person."
- Archive remains private and non-social.

---

## Out of Scope

- Expression templates
- Card/report export
- User insight profile that persists sensitive inferences
- Gift mode, confession mode, couple features, recipient pages, social sharing
- BLE, emotion light, NFC, plush device integration

---

## Sprint Exit Criteria

- ZEROON can show a basic long-term companion view.
- Memory and reflection support user self-understanding without narrowing into an emotional relationship tool.
- Ready for Expression and Export exploration in the next roadmap phase.
