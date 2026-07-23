# Sprint 10 String Inventory V1

Status: Accepted for implementation
Prepared: 2026-07-22

## Purpose

This inventory is the S10-01 source map for all current mobile and companion
language-bearing behavior. S10-02 through S10-05 must move these surfaces to
reviewed Simplified Chinese and English resources without translating private
user-authored values.

The inventory is organized by behavior rather than by copying every current
Chinese sentence. Generated localization keys remain the implementation source
of truth once introduced.

## Mobile foundation and shared behavior

| Source | Required inventory |
|---|---|
| `mobile/lib/main.dart` | App metadata where visible, authentication/bootstrap failure, encounter failure, neutral startup behavior |
| `mobile/lib/common/zeroon_design.dart` | Shared processing label, all state labels, reusable buttons/headers, accessibility semantics introduced by shared controls |
| `mobile/lib/common/api_client.dart` | `Accept-Language` propagation and bounded error classification; no raw Dio text in UI |
| locale foundation to be added under `mobile/lib/locale/` and `mobile/lib/l10n/` | Preference labels, system-language label, locale resolution, sync-pending copy, formatting, ARB descriptions and placeholders |

State enum labels requiring keys are `IDLE`, `CALM`, `FOCUS`, `CREATE`,
`TIRED`, `OVERLOAD`, and `CONFUSED`. Enum wire values and API property names are
not translated.

## Authentication and first encounter

| Source | Required inventory |
|---|---|
| `mobile/lib/auth/login_screen.dart` | Welcome and reassurance copy, mobile/code labels, request-code and login actions, agreement/privacy copy, validation, request/login failures, local-development notice, discoverable language control |
| `mobile/lib/auth/auth_controller.dart` | Locale synchronization states after login/logout; controller errors must become bounded UI states |
| `mobile/lib/auth/auth_models.dart` | Account preference parsing and serialization; wire enum stays language-neutral |
| `mobile/lib/my_zeroon/encounter_screen.dart` | First-meeting title/body/actions, already-met state, nameplate presentation, loading/error/retry |

The language control must be understandable without reading the current
language. Product/legal links may keep their current availability boundary, but
the surrounding UI cannot claim that untranslated legal material is localized.

## Home, state, and navigation

| Source | Required inventory |
|---|---|
| `mobile/lib/home/home_shell.dart` | Bottom navigation labels and semantics for Now, Archive, Growth, and Profile entry behavior |
| `mobile/lib/home/now_screen.dart` | Greeting, section labels, state selector and hints, active-duration text, Reset action, archive summary, streak/day copy, weekday labels, empty/loading/error/retry, number/date/duration pluralization |
| `mobile/lib/state/state_controller.dart` and state models | Bounded failure mapping around state read/change; stored enum values unchanged |

Greeting must not assume a fixed time of day after localization. Dates,
weekdays, durations, and plural forms use locale formatters instead of manual
Chinese suffix concatenation.

## Reset and completion

| Source | Required inventory |
|---|---|
| `mobile/lib/record/reset_screen.dart` | Header, current-state status, duration, content/goal fields and hints, validation, save action, processing, save failure |
| `mobile/lib/record/record_complete_screen.dart` | Completion header, status, saved confirmation, record labels, fallback reflection, return/archive actions, time formatting, companion loading/error/retry/safety states |
| completion prompt in `record_complete_screen.dart` | Reviewed Chinese and English prompt variants; no inference from the saved Record |

Unsaved input and stored Record fields are values, not localization resources,
and must survive an immediate language switch unchanged.

## Archive, detail, and Memory

| Source | Required inventory |
|---|---|
| `mobile/lib/record/archive_screen.dart` | Archive title, privacy copy, counts, empty/filter/calendar states, dates/times, record labels, Memory entry, AI observation loading/failure/retry/safety copy |
| observation prompt in `archive_screen.dart` | Reviewed Chinese and English prompt variants; prompt continues to use only consented Memory context |
| `mobile/lib/record/record_detail_screen.dart` | Detail title, private label, ids/state/time labels, content section headings, loading/error/retry |
| `mobile/lib/record/record_models.dart` | Preview fallback behavior only; goal/content remain original text |
| `mobile/lib/memory/memory_screen.dart` | Header/privacy explanation, empty/loading/error/retry, enabled/paused state, AI-context permission and honest paused-state explanation, mutation receipts, deletion confirmation, source link and unavailable state, dates |

Record, Memory, AI summary, and earlier companion response bodies are never
entered into ARB files and never translated during display or locale changes.

## Growth

| Source | Required inventory |
|---|---|
| `mobile/lib/growth/growth_screen.dart` | Header and restrained framing, metrics and units, first-record/companion-day dates, yearly observation loading/error/retry, disclosure panel, state-derived narrative, empty state, day/count pluralization |
| `mobile/lib/growth/growth_models.dart` | Server observation values remain data; enum labels and surrounding explanations are localized separately |

The current state-derived narrative must be reviewed in both languages without
becoming diagnostic or label-driven. English copy cannot increase streak
pressure.

## Profile, Settings, and data control

| Source | Required inventory |
|---|---|
| `mobile/lib/profile/profile_screen.dart` | Profile header/introduction, optional field labels and hints, avatar/age option labels, AI-profile consent and explanation, save states, companion states, data export, logout, account deletion confirmation/results, loading/error/retry |
| `mobile/lib/profile/profile_models.dart` | Stored Profile values remain original text; option enum values remain language-neutral |
| `mobile/lib/data_control/data_control_repository.dart` | Bounded export/deletion failures; no raw transport exception in UI |
| language Settings surface introduced in S10-04 | Follow System/Chinese/English labels, immediate-change behavior, local-only pending-sync feedback, retry and accessibility copy |

Language preference is not placed inside the AI-profile consent section. The UI
may share the Settings screen, but the data and explanatory hierarchy stay
separate.

## Companion and server-owned deterministic copy

| Source | Required inventory |
|---|---|
| `mobile/lib/companion/ai_reflection_card.dart` | Loading, retry, failure, safety-boundary label and accessibility semantics |
| `backend/.../prompt/PromptTemplateService.java` | Locale-specific provider language instruction composed with the active versioned prompt |
| `backend/.../companion/CompanionService.java` | Simplified Chinese and English deterministic fallback and safety notice selected by resolved locale |
| `backend/.../companion/SafetyBoundaryService.java` | Shared authority/categories, bilingual term coverage, localized deterministic refusal selected outside the provider |
| companion controller/service tests | Supported/unsupported/missing `Accept-Language`, account fallback, provider success/fallback/refusal, provider bypass, content-free logs |

Server Problem Details remain machine-readable. Mobile maps status and bounded
problem codes to localized copy instead of displaying backend exception bodies.

## Content that stays unchanged

The following are deliberately excluded from translation resources:

- user-authored Record goal/content and unsaved drafts;
- stored Record AI summaries and prior companion replies;
- Memory title/summary and source content;
- Profile nickname, occupation, identity, and self-description;
- conversation history;
- companion display name and nameplate serial;
- API paths, JSON properties, database identifiers, enum wire values, safety
  labels, correlation ids, and export property names;
- brand marks such as `ZEROON`; English-style section marks such as
  `ZERO RECORD` require visual review but are not automatically translated.

## Error and accessibility audit

The current app exposes raw `error.toString()` values on authentication,
encounter, Now, Archive, Record Detail, Growth, and Profile paths. Sprint 10
must replace those render paths with bounded localized states. Debug details may
remain in development-only diagnostics if they contain no private content or
secrets, but never in user copy.

Each interactive icon, language option, destructive control, state chip,
navigation destination, calendar control, and retry action needs localized
semantics or tooltip text. Both locales require narrow-width tests for wrapped
labels, confirmation dialogs, privacy/safety explanations, and text scaling.

## Completeness gate

S10-04 is incomplete if any shipped mobile state uses an untranslated literal
for user-facing meaning. The implementation review must search for remaining
`Text`, label, hint, tooltip, dialog, SnackBar, error, date/time, duration, and
prompt literals and either:

1. move them to generated localization resources;
2. classify them as original user/server data;
3. classify them as language-neutral product marks or wire values with an
   explicit review note.

Both locales must cover success, empty, loading, error, retry, destructive
confirmation, safety, privacy, accessibility, and offline/pending-sync states.
