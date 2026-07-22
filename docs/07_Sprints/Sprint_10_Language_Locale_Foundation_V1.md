# Sprint 10 Language and Locale Foundation V1

Status: Planned
Prepared: 2026-07-22

## Sprint Goal

Give users an explicit, persistent choice of interface language while keeping
ZEROON's mobile experience, companion responses, fallback, refusal, and safety
boundaries coherent in that language.

This sprint occupies Sprint 10. Any previously discussed but undocumented
Sprint 10 scope moves to Sprint 12 and must be formalized separately rather
than reconstructed from memory.

## Product Decision

### Mainline fit

Language choice supports ZEROON as a long-term companion and private memory
system across devices and cohorts. It changes the interaction environment; it
does not define the user or reinterpret their history.

### Drift risk

- Do not treat language as nationality, location, culture, or identity.
- Do not infer a preferred language from private Record or Memory content.
- Do not auto-translate, rewrite, or normalize user-authored history.
- Do not ship a language selector while leaving AI fallback, refusal, safety,
  loading, or error states in a different language.
- Do not expand this sprint into translation services, public sharing, or
  multilingual content generation.

### Abstract capability

**User-controlled interaction language**: one explicit preference consistently
applied to product chrome and bounded companion behavior while private content
remains in its original form.

### Roadmap decision

Accept now as the foundation before further user-facing expansion. Support
Simplified Chinese, English, and Follow System. Defer additional languages,
history translation, admin localization, and language-specific marketing.

## Locale Resolution

The implementation must define one deterministic resolution policy:

1. authenticated account preference when explicitly set;
2. explicit device preference before authentication or while offline;
3. supported operating-system locale;
4. Simplified Chinese fallback.

`FOLLOW_SYSTEM` remains a real preference. It is not converted permanently to
the system language at save time, so different devices may follow their own
system locale.

Changing language in Settings updates the current device immediately. When
authenticated, the same explicit choice is persisted to the account for later
sessions. Login must remain usable before account preferences are available.

## Implementation Sequence

| Item | Status | Done when |
|---|---|---|
| S10-01 Locale architecture and inventory | Planned | Locale resolution, supported identifiers, account/device precedence, prohibited inference, affected strings, and API/data decision are documented before implementation |
| S10-02 Mobile localization foundation | Planned | Flutter localization generation, Simplified Chinese and English resources, locale controller, pre-auth persistence, and no-flash startup behavior exist |
| S10-03 Account preference contract | Planned | An authenticated user can read and update an explicit locale preference with migration, test schema, ownership, export, OpenAPI, and device-sync behavior aligned |
| S10-04 Settings and complete mobile copy | Planned | Login exposes a discoverable language entry; Settings switches immediately; all current user-facing mobile success, empty, loading, error, retry, confirmation, and safety copy is localized |
| S10-05 Companion language consistency | Planned | Provider prompt instruction, success response expectation, fallback, refusal, and safety notice follow the resolved preference without using Profile or Memory consent as a shortcut |
| S10-06 Regression and runtime acceptance | Planned | Widget/backend tests cover resolution, persistence, immediate switching, restart/login behavior, fallback/refusal, original-content preservation, and both locale runtime smokes |

## S10-01 Architecture Questions

Before code changes, decide and document:

- canonical identifiers: `FOLLOW_SYSTEM`, `ZH_CN`, and `EN`;
- whether account preference belongs on `users` or a dedicated preferences
  resource; it must not be mixed with AI Profile consent;
- the authenticated preference endpoint and conflict behavior;
- local persistence mechanism for pre-auth and offline startup;
- how a server-side companion request resolves locale without holding the
  external provider call inside a database transaction;
- how unsupported or malformed stored values fall back safely;
- whether exports include the explicit preference while keeping JSON field
  names stable.

## Mobile Experience Requirements

- Login has a quiet, discoverable language entry; a user must not need to read
  Chinese in order to find English.
- Settings presents language as a normal preference, not an identity profile.
- Switching is local and immediate. It does not refresh the whole app, discard
  navigation state, or clear an in-progress Record.
- The initial frame uses the resolved locale or a neutral loading state; it
  must not visibly flash from one language to another.
- Screen hierarchy, spacing, and ZEROON's restrained tone remain consistent in
  Chinese and English. English may wrap to additional lines without clipping.
- Technical API errors are mapped to localized, recoverable product copy.
- Dates, times, and numbers follow locale conventions without changing stored
  timestamps or numeric values.

## AI and Safety Requirements

- Locale is an operational request preference, not private Profile context and
  not a derived trait.
- The system prompt asks the provider to answer in the resolved language unless
  the user explicitly requests another language in the current message.
- Deterministic safety evaluation remains language-independent in authority and
  supports the documented Chinese and English high-risk terms.
- Refusal, fallback, and `safetyNotice` are selected server-side from reviewed
  localized copy; they are never delegated to the provider.
- Usage metadata may record a bounded locale identifier only if an explicit
  observability decision is later accepted. It must not store request text or
  infer language from private content.
- Record, Memory, Profile, conversation history, and exports preserve the
  user's original text. No background translation is added.

## Affected Surfaces

### Backend, database, and OpenAPI

- explicit account locale preference and migration;
- authenticated read/update contract and export alignment;
- companion locale resolution before provider execution;
- localized deterministic fallback, refusal, and safety notice;
- tests for ownership, invalid values, default behavior, and no private-text
  logging.

### Mobile

- Flutter localization packages, generated resources, and locale controller;
- device-local persistence and authenticated synchronization;
- Login and Settings language controls;
- all current user-facing screens and shared widgets;
- Widget tests at Chinese and English sizes, including narrow mobile width.

### Documentation and operations

- OpenAPI and data lifecycle documentation;
- language-key review rules and translator context;
- release checklist for missing keys, mixed-language states, overflow, AI
  language, fallback, and refusal.

### Explicitly unchanged

- admin remains in its current language;
- API property names and enum wire values remain language-neutral;
- saved user-authored content remains unchanged;
- no automatic translation service or additional model call is introduced.

## Acceptance Criteria

- A signed-out user can choose English without first navigating through a
  Chinese-only Settings flow.
- `FOLLOW_SYSTEM`, `ZH_CN`, and `EN` resolve deterministically and survive app
  restart; authenticated choices also survive sign-in on another device.
- Switching language updates the visible mobile interface immediately without
  losing current navigation or unsaved Record input.
- Every shipped mobile screen has complete Chinese and English success, empty,
  loading, error, retry, destructive-confirmation, and accessibility copy.
- Companion success, provider fallback, deterministic refusal, and safety
  notice use the resolved language.
- English and Chinese safety tests trigger the same boundary categories and do
  not call the provider when deterministically blocked.
- Existing Record, Memory, Profile, and conversation content is byte-for-byte
  unchanged by locale switching.
- Data export includes only the explicit preference decision and never a
  language inferred from user content.
- No locale value, translated private content, API key, prompt body, or
  exception body leaks into logs beyond an explicitly approved bounded enum.
- Flutter analyze/tests, backend tests, OpenAPI lint, migration smoke, narrow
  viewport review, and the full ZEROON quality gate pass.

## Out of Scope

- Traditional Chinese or a third language;
- automatic translation of Records, Memory, Profile, or conversations;
- language detection from private content;
- localized admin console;
- localized marketing site, App Store assets, support operations, or legal
  documents;
- voice, speech recognition, or text-to-speech;
- region, currency, timezone, or country selection beyond locale formatting.

## Sprint Exit

- Users can understand and control the language ZEROON uses with them.
- Product chrome and bounded AI behavior remain coherent in Chinese and
  English, including failure and safety paths.
- Private historical content remains untouched and no identity inference is
  introduced.
- The full quality gate and two-locale runtime acceptance pass before Sprint 11
  begins.
