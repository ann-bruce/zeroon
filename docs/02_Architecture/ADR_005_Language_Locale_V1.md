# ADR 005 Language and Locale V1

Status: Accepted
Date: 2026-07-22
Scope: Sprint 10 Language and Locale Foundation

## Context

ZEROON currently renders Simplified Chinese strings directly from Flutter
widgets and helper functions. The backend has no account language preference,
and deterministic companion fallback, refusal, and safety copy is Chinese-only.
Flutter has no localization generation, locale controller, or non-sensitive
device preference store.

Language is an interaction preference. It is not nationality, location,
culture, identity, Profile context, or a property to infer from Record, Memory,
conversation, or other private text.

## Decision

### Canonical preferences and effective locales

Persist exactly one account and device preference:

- `FOLLOW_SYSTEM`;
- `ZH_CN`;
- `EN`.

Only two effective locales are sent to product behavior:

| Preference or system locale | Effective locale | BCP 47 value |
|---|---|---|
| `ZH_CN` | Simplified Chinese | `zh-CN` |
| `EN` | English | `en` |
| `FOLLOW_SYSTEM` with `zh`, `zh-Hans`, or `zh-CN` | Simplified Chinese | `zh-CN` |
| `FOLLOW_SYSTEM` with an English locale | English | `en` |
| `FOLLOW_SYSTEM` with any other or malformed locale | Simplified Chinese | `zh-CN` |

Traditional Chinese is not silently mapped to Simplified Chinese as a claim of
language support. An unsupported `zh-Hant` system locale follows the documented
Simplified Chinese product fallback until Traditional Chinese is implemented.

### Resolution and synchronization

Before authentication and while offline:

1. an explicit device preference, including `FOLLOW_SYSTEM`;
2. the supported operating-system locale when following the system;
3. Simplified Chinese fallback.

After authentication bootstrap:

1. a pending explicit device selection that has not yet synced is applied
   immediately and sent to the account;
2. otherwise the account preference is authoritative and is cached locally;
3. `FOLLOW_SYSTEM` remains the stored preference and is resolved independently
   on each device;
4. malformed stored values are treated as `FOLLOW_SYSTEM`, resolved safely,
   and repaired on the next successful write.

Changing Settings updates the local UI first. If the account write fails, the
device keeps the selection, marks it pending, and shows a localized recoverable
message. The pending value is retried after authentication or the next explicit
save. Logout clears credentials but does not clear the device language.

The device store therefore keeps the preference plus whether an explicit
choice is pending synchronization. It never stores private content and uses a
normal preferences store rather than credential storage.

### Flutter implementation boundary

S10-02 will use Flutter's generated localization flow:

- `flutter_localizations` from the Flutter SDK;
- ARB resources for `zh_CN` and `en`;
- generated strongly typed keys rather than string lookup maps;
- a Riverpod locale controller initialized before the first localized frame;
- `shared_preferences` for the non-sensitive device preference and pending
  synchronization marker;
- `MaterialApp.localizationsDelegates`, `supportedLocales`, and the controller's
  resolved locale (`null` only for `FOLLOW_SYSTEM`).

The app bootstraps the local preference before rendering language-bearing UI.
If storage cannot be read, it renders a neutral loading surface and then uses
the deterministic fallback; it does not render Chinese login copy and replace
it with English a frame later.

Dates, times, weekdays, durations, counts, and plurals move behind localized
formatters. Stored timestamps, numeric values, and API enum values do not
change.

### Account persistence and API

S10-03 will add `users.language_preference` as a non-null string enum with
default `FOLLOW_SYSTEM`. A dedicated table is rejected for the first bounded
account preference because it adds lifecycle and join complexity without an
independent aggregate. The field remains separate from `user_profiles` and AI
consent.

The authenticated contract is:

- `GET /api/v1/me/preferences/language` returns the stored preference;
- `PUT /api/v1/me/preferences/language` idempotently replaces it;
- request and response field: `languagePreference`;
- unsupported or malformed request values return `400 application/problem+json`;
- authentication and ownership follow the existing `/me/**` boundary.

The login/refresh `AuthUser` and `GET /me` payloads also expose
`languagePreference` so the mobile bootstrap does not require an avoidable
extra request. Existing API field names and language-neutral enum wire values
remain unchanged.

The explicit preference is part of the account data export. Adding it advances
the export schema identifier from `zeroon-beta-export-v1` to
`zeroon-beta-export-v2`; all existing export property names remain stable.
Account hard deletion removes the preference with the user row.

### Request language and companion behavior

The mobile client attaches the resolved BCP 47 value as the standard
`Accept-Language` header. It sends an effective locale (`zh-CN` or `en`), not
`FOLLOW_SYSTEM`.

For companion requests, the backend resolves language in this order:

1. the first supported `Accept-Language` range by quality weight;
2. a concrete authenticated account preference (`ZH_CN` or `EN`);
3. Simplified Chinese when the stored preference is `FOLLOW_SYSTEM`, missing,
   or malformed.

Unsupported header ranges are ignored and never persisted. The backend does
not inspect the message, Profile, Record, Memory, or conversation to infer
language. The resolved enum is established before provider execution and does
not add a transaction around the external call.

The resolved locale selects:

- a reviewed provider instruction asking for that language unless the current
  user message explicitly requests another language;
- localized deterministic fallback copy;
- localized deterministic refusal copy;
- localized `safetyNotice`.

Safety rule authority and labels remain language-neutral. Chinese and English
terms are evaluated against the same categories, and a deterministic refusal
still bypasses the provider. Mobile-authored companion prompts are localized so
they do not contradict the selected language.

Locale is not added to AI usage metadata in Sprint 10. A future observability
change would require a separate bounded decision and must still exclude prompt,
reply, Record, Memory, Profile, and conversation content.

## Conflict and failure behavior

- A signed-out explicit choice is never discarded merely because login begins.
- A pending local choice wins once, writes to the account, and then clears its
  pending marker after the server confirms the same value.
- Without a pending local choice, the account wins and refreshes the device
  cache, including an explicit `FOLLOW_SYSTEM` value.
- A failed account write does not roll the visible UI back; it remains pending
  and the user is told that this device changed but cross-device sync has not.
- An unsupported OS locale, header, account value, or ARB lookup falls back to
  Simplified Chinese without reading private content.
- Raw Dio, Java exception, and validation messages are never rendered directly;
  mobile maps bounded error states to localized product copy.

## Original-content boundary

Locale switching must not mutate, translate, normalize, regenerate, or replace:

- Record goal, content, or AI summary already stored;
- Memory title or summary;
- Profile nickname, occupation, or self-description;
- conversation messages or prior companion replies;
- exported private text.

Localized labels may surround those values, but the values themselves remain
byte-for-byte unchanged. New provider replies follow the active interaction
language; old replies remain as originally received.

## Consequences

- Language works before login, offline, after login, and across devices without
  being confused with identity or AI consent.
- `FOLLOW_SYSTEM` can behave correctly on devices with different locales.
- Backend deterministic states remain coherent even when the provider fails or
  is bypassed.
- S10-02 and S10-03 must add dependencies, migration, test schema, OpenAPI,
  mobile models, and synchronization tests before UI translation expands.
- Admin, marketing, legal documents, support operations, and automatic content
  translation remain out of scope.

## Verification obligations

- unit tests for all preference/system/header resolution combinations;
- startup tests proving no language-bearing flash;
- login tests for pending-device-wins and account-wins paths;
- API tests for read, idempotent update, invalid value, ownership, auth payload,
  export V2, and deletion;
- companion tests for Chinese/English success instruction, fallback, refusal,
  safety notice, and provider bypass;
- widget tests for immediate switching, restart, logout retention, narrow-width
  English layout, and localized recoverable errors;
- persistence tests proving locale switching leaves original private content
  unchanged.
