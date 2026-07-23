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

### V1.2

- Record templates
- Write to future as a template, not a relationship-specific product
- Optional memory card export from record detail

### V2

- Model settings
- Device link
- Emotion Light
- NFC or physical ZEROON experiments

## Guardrails

- User data is private by default.
- AI can recommend, but the user confirms any state change.
- User insights must be visible, deletable, and disableable.
- Profile fields must be optional and user-controlled.
- Reflection cannot diagnose or define the user.
- Export is for saving memory first, not social distribution.
- Device link must not expose private content by default.
