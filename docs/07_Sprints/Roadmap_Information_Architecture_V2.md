# Roadmap Information Architecture V2

## Decision

ZEROON uses a "few entries, many capabilities" structure.

Sprint 01 primary navigation:

- Now
- Reset
- Archive

Future primary navigation candidate:

- Now
- Reset
- Archive
- My

The following are system capabilities, not early primary navigation tabs:

- Growth
- Reflection
- Expression
- Export
- Settings
- Device Link

## Product Mainline

```text
Now awareness
  -> Reset record
  -> Archive memory
  -> Reflection and self-understanding
  -> Companion growth
  -> Future device link
```

## Capability Model

| Capability | Product Meaning | Placement |
|---|---|---|
| Record | Save current state, thoughts, progress, and important fragments | Reset |
| Memory | Preserve user-owned records and important fragments | Archive |
| Reflection | Help users understand recent patterns and changes | Archive / Growth cards |
| Growth | Show companion days, first record, cached entries, and stage changes | Now card / My |
| Expression | Help users organize words they want to keep or say | Record templates |
| Export | Generate cards, images, or reports from existing records | Record detail / Growth |
| Device Link | Connect Emotion Light, plush ZEROON, NFC, or future devices | Settings / Device |

## Product Optimization And Feature Backlog

- Independent optimization and new-feature candidates are ordered in
  `../08_Roadmap/ZEROON_Product_Backlog_V1.md`.
- Backlog placement does not attach an item to any completed Sprint or approve
  a new Sprint, production change, cohort, notification, or payment action.
- Trust and ownership gaps are considered before broader capture, reflection,
  or engagement expansion.

## Naming Rules

Do not use these as official feature or navigation names:

- confession gift
- gift mode
- couple feature
- recipient page
- social sharing
- public feed
- relationship tool

These can exist only as future examples or marketing tests after the abstract
capability is validated.

## Version Plan

### Sprint 01

- Login
- Now
- Reset
- Archive

### Sprint 02

- AI reflection in Archive and record success states
- Prompt and provider baseline
- No persistent hidden profile

### Sprint 03

- Growth with real data
- Memory detail and recent pattern reflection
- No social or gift-oriented features

### Sprint 04

- State lifecycle: Now starts the current state interval
- Reset ends the active state and links it to a zero record
- Archive and Growth can use state duration without diagnostic labels

### V1.1

- My page
- Growth entry
- Data and privacy settings
- User profile settings for optional self-introduction
- AI permission to use profile context

### Sprint 10

- Language and Locale Foundation
- Follow System, Simplified Chinese, and English
- Complete mobile, companion fallback/refusal, and safety-language consistency
- Original user content remains untranslated

### Sprint 11

- Help, Contact, and Feedback Foundation
- Reachable before login and during API outage
- Private, trackable requests with real operator replies and admin audit
- No automatic attachment of Record, Memory, conversation, or log content

### Sprint 12

- Closed Beta Evidence and Recruitment Readiness
- First-party typed, content-free product evidence with explicit notice
- 180-day maximum, account-deletion hard deletion, and aggregate-only ADMIN
  reporting with cells below five participants suppressed
- First cohort limited to at most 20 invited adults
- Previously undocumented Sprint 10 scope is not reconstructed or approved

### Sprint 13

- Return Loop Foundation and Owner Acceptance
- Closed on 2026-08-18 with no remaining Sprint task
- Quietly resurface one eligible user-owned moment after time passes
- Reset capture hierarchy and first-loop orientation are owner-accepted
- No AI importance inference, private lock-screen text, generic chat, streak
  pressure, scores, or social mechanics

### Sprint 14

- Record Reliability and Ownership
- Closed on 2026-08-22 after engineering, PostgreSQL-backed, and real iOS
  owner acceptance
- Durable Reset drafts and one-owned-Record deletion
- Linked Memory, cue, Archive, Growth, export, and AI lifecycle closure
- Plan: `Sprint_14_Record_Reliability_And_Ownership_V1.md`

### Sprint 15

- Growth and Memory Clarity
- Active on 2026-08-22 after bounded intake; `S15-01` through `S15-03` accepted
- Remove performance pressure and fixed-state implications
- Make preservation, source, pause, delete, and AI-use controls understandable
- Plan: `Sprint_15_Growth_And_Memory_Clarity_V1.md`

### Sprint 16

- Privacy and Release Readiness
- App access/background protection and bounded readable export
- Production, support, AI-safety, privacy, and App Store package acceptance
- No production release or App Store submission without explicit owner approval
- Plan: `Sprint_16_Privacy_And_Release_Readiness_V1.md`

### Sprint 17

- Production Launch and User Validation
- Separate acquisition, activation, return, retention, and trust evidence
- First approximately 20 adults establish stability before bounded expansion
- Plan: `Sprint_17_Production_Launch_And_User_Validation_V1.md`

### Sprint 18

- Evidence-Led Iteration
- Exact feature scope remains unset until Sprint 17 evidence exists
- Select one bounded problem rather than changing multiple core variables
- Plan: `Sprint_18_Evidence_Led_Iteration_V1.md`

### V1.2

- Record templates
- Write to future as a template, not a relationship-specific product
- Optional memory card export from record detail

### V2

- Model settings
- Device link
- Emotion Light
- NFC experiments

### Sprint 19 Candidate

- Physical ZEROON Entitlement Pilot
- One manually approved entitlement per participant and campaign
- Idempotent claim, bounded fulfillment, and minimal encrypted delivery data
- No rewards, payment, store, gifting, BLE, NFC, or mass-delivery promise
- Entry requires Sprint 17 digital-value evidence, one reviewed sample,
  supplier quotations, fulfillment rules, and explicit owner approval
- Plan: `Sprint_19_Physical_ZEROON_Entitlement_Pilot_V1.md`

The Sprint 19 number reserves a future candidate only. It does not move V2
hardware work ahead of digital value, supply, privacy, or owner gates. The
accepted sequence is detailed in
`../08_Roadmap/Sprint_14_19_Execution_Roadmap_V1.md`.

## Guardrails

- User data is private by default.
- AI can recommend, but the user confirms any state change.
- User insights must be visible, deletable, and disableable.
- Profile fields must be optional and user-controlled.
- Reflection cannot diagnose or define the user.
- Export is for saving memory first, not social distribution.
- Device link must not expose private content by default.
