# ZEROON Data Control Lifecycle V1

Status: Implemented for closed Beta
Effective: 2026-07-14

## Product Decision

ZEROON treats data portability and a clear exit as product capabilities. The
closed-Beta implementation is intentionally synchronous and verifiable:

- `GET /api/v1/me` returns the authenticated account summary;
- `GET /api/v1/me/export` returns a versioned JSON data copy;
- `DELETE /api/v1/me/deletion` completes hard deletion before returning `204`;
- `POST /api/v1/auth/logout` revokes the supplied owned refresh session and is
  idempotent.

The previous planned `/users/me` and `202 Deletion scheduled` contract was not
implemented and has been removed from OpenAPI. A future asynchronous deletion
workflow must use a new reviewed contract rather than pretending to be the
current behavior.

## Beta Export Scope

`zeroon-beta-export-v2` includes:

- account identity, state, status, roles, explicit language preference, and
  creation time;
- optional Profile and AI-context permission;
- the user's private ZEROON companion;
- device/session metadata without credentials;
- state history and state sessions;
- Zero Records, including user content and AI summaries;
- conversations and messages;
- current and expired Memory entries;
- content-free AI usage metadata.

The export excludes access tokens, refresh tokens, refresh-token hashes,
verification codes, provider secrets, system configuration, prompt-template
content, and records belonging to another user. The Beta mobile client copies
the JSON data copy to the system clipboard; the API also supplies an attachment
filename for clients that support file downloads.

V2 adds only the explicit `languagePreference` account field while preserving
all V1 property names. It never exports a language inferred from Profile,
Record, Memory, conversation, or other private text.

This product export is not a substitute for jurisdiction-specific data-access
or records-of-processing obligations.

## Deletion Semantics

Deletion is immediate, authenticated, owner-scoped, and idempotent. The first
successful request deletes the user row; database foreign keys then remove:

- roles and refresh sessions;
- the account language preference stored on the deleted user row;
- Profile and private ZEROON companion;
- state history and state sessions;
- Zero Records;
- conversations and messages;
- Memory entries.

Repeating the request with the still-valid access-token signature returns `204`
without recreating state. Every refresh token belonging to the deleted account
becomes unusable.

## Explicit Retention Boundary

The following operational rows may remain only in deidentified form:

- AI usage rows retain provider/model, outcome, latency, template version,
  character counts, optional provider-reported token counts, and error code;
  `user_id` and `conversation_id` become null, and these rows never contain
  prompt, Memory, record, message, or reply text;
- audit events may remain for security/accountability with `actor_user_id`
  null; private record or message bodies must not be placed in audit metadata;
- administrator-created prompt templates may remain with `created_by` null.

No endpoint returns success while retaining the user's Profile, records,
messages, Memory summaries, mobile number, refresh sessions, or companion row.

## Failure and UX Rules

- A failed delete returns an error and leaves the local session intact; the UI
  says that deletion did not complete.
- The mobile client clears local credentials only after account deletion
  succeeds.
- Logout attempts remote revocation, but always permits local exit when the
  network is unavailable.
- The delete action is visually secondary, requires explicit confirmation,
  and states that deletion cannot be undone.
