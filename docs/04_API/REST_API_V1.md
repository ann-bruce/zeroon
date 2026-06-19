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

Access tokens expire after 15 minutes. Refresh tokens rotate and expire after
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
  "message": "今天有点累"
}

Response

{
  "reply": "先归零一下，我们慢慢来。"
}

---

## Memory

### Query Memory

GET /memory

### Get Summary

GET /memory/summary

---

## Admin

### Users

GET /admin/users

### Prompts

GET /admin/prompts

GET /admin/prompts/{promptId}

POST /admin/prompts

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
