# REST API V1

This file is a human-readable overview. The canonical contract is
`OpenAPI_V1.yaml`; implementation and clients must not infer fields from the
examples below.

Base URL

/api/v1

---

## Auth

### Login

POST /auth/login

Request

{
  "mobile": "13800000000",
  "code": "123456"
}

Related authentication endpoints:

- `POST /auth/codes`
- `POST /auth/refresh`
- `POST /auth/logout`

App access tokens carry USER authority only and expire after the configured
short lifetime (30 minutes by default). Refresh tokens rotate and expire after
30 days.

Response

{
  "code": 0,
  "message": "success",
  "data": {
    "token": "jwt-token"
  }
}

---

## User

### Get Profile

GET /users/me

Response

{
  "uid": "U10001",
  "nickname": "Bruce",
  "currentState": "FOCUS"
}

---

## Closed-Beta Evidence

- `GET /me/preferences/beta-evidence` returns the explicit default-off
  collection choice and required notice version.
- `PUT /me/preferences/beta-evidence` records an enable or disable choice only
  for the current reviewed notice.
- `POST /evidence/events` accepts one authenticated schema-v1 event with only
  the event-specific typed properties in OpenAPI.

Evidence ingestion uses a random internal subject, contains no private text or
direct identity, and is idempotent per client event id. A disabled choice
stores nothing. Account export includes retained owned events without internal
ids; account deletion hard-deletes the subject and events.

The mobile client uses a bounded in-process best-effort queue and never makes a
primary operation depend on evidence availability. Support request content is
not an evidence event.

---

## State

### Get Current State

GET /state/current

### Change State

POST /state/changes

Request

{
  "state": "FOCUS"
}

---

## Zero Record

### Create Record

POST /records

Request

{
  "state": "FOCUS",
  "content": "今天完成了架构设计",
  "goal": "完成API设计"
}

### Query Records

GET /records

---

## Companion

### Chat

POST /companion/messages

Request

{
  "purpose": "COMPANION_CHAT",
  "message": "今天有点累"
}

Response

{
  "reply": "先归零一下，我们慢慢来。",
  "outcome": "SUCCESS",
  "latencyBucket": "FROM_500_TO_1499_MS",
  "promptVersion": "COMPANION_REFLECTION_V7",
  "modelAlias": "PRIMARY",
  "contextClasses": ["MEMORY"]
}

Evidence metadata is content-free. `contextClasses` names only the enabled
context class used for the turn and never contains the context itself.
`purpose` is one of `COMPANION_CHAT`, `RESET_COMPLETION`,
`ARCHIVE_OBSERVATION`, or `GROWTH_OBSERVATION`. It selects a server-owned task
layer; user or mobile-authored prose remains untrusted data and cannot redefine
the task, Persona, privacy, or safety policy.

Before Prompt selection or context assembly, the server evaluates deterministic
safety boundaries. A reviewed self-harm signal bypasses the provider and
returns `promptVersion: SAFETY_SELF_HARM_V1_REVIEW_PENDING` with a content-free
path label retained only in usage metadata. The API does not expose a clinical
risk score and does not contact another person or emergency service.

---

## Memory

### Query Memory

GET /memory

GET /memory/{memoryId}

### Get Summary

GET /memory/summary

## Growth

GET /growth/summary

Returns elapsed companionship, first owned Record date, and the count of
owned Records that can still be revisited.

GET /growth/state-pattern

Returns the count of visible state confirmations in a time window. It does
not include a dominant state, distribution, or generated observation copy.

---

## Admin

### Authentication

`POST /admin/auth/email/codes`

`POST /admin/auth/email/login`

The management portal has its own email-code flow. Only normalized emails in
`ZEROON_ADMIN_EMAILS` receive a code, but the request endpoint returns the same
accepted response for every valid email shape. Admin codes use a separate
one-time-code namespace and cannot create an App session. Successful login
returns a short-lived ADMIN token without a refresh token; ordinary App login
always returns USER authority even when the backing identity also has an
operational role.

### Users

GET /admin/users

### Prompts

GET /admin/prompts

GET /admin/prompts/{promptId}

POST /admin/prompts

POST /admin/prompts/{promptId}/review

POST /admin/prompts/{promptId}/evaluations

POST /admin/prompts/{promptId}/activate

Prompt content is immutable. A new version starts in `PENDING`, must be
approved by an administrator other than its creator, and becomes runtime-active
only through the explicit activation endpoint. A forward activation also
requires the latest content-free evaluation record to pass the Persona
thresholds. Activating an older approved version is recorded as a rollback and
remains available when a new candidate fails.

---

## Standard Response

Successful responses use the resource schema and the HTTP status code.

Errors use `application/problem+json` with:

```json
{
  "type": "https://api.zeroon.ai/problems/validation",
  "title": "Invalid request",
  "status": 400,
  "detail": "One or more fields are invalid.",
  "traceId": "01J..."
}
```
