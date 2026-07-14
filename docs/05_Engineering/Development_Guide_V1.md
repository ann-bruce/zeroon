# ZEROON Development Guide V1

## Technology Stack

### Mobile
Flutter 3.x
Riverpod
GoRouter
Dio

### Admin
React
Ant Design
Vite

### Backend
Java 21
Spring Boot 3.x
Spring Security
Spring AI
Spring Data JPA
Gradle

### Database
PostgreSQL 16
Redis 7

### Deployment
Docker
Docker Compose
Nginx
GitHub Actions

---

## Code Structure

backend/

src/main/java/com/zeroon

├── user
├── state
├── record
├── companion
├── memory
├── admin
├── common
└── config

---

## Naming Rules

Class:
UserService

Method:
getCurrentState()

Variable:
currentState

Constant:
DEFAULT_STATE

---

## API Rules

Prefix:

/api/v1

Response:

Successful responses use the resource schema and HTTP status code.

Errors use RFC 9457-compatible `application/problem+json`.

The canonical contract is:

docs/04_API/OpenAPI_V1.yaml

---

## Database Rules

snake_case

Examples:

user_id
created_at
updated_at

---

## Git Rules

feature/*
release/*
hotfix/*

Commit:

feat:
fix:
docs:
refactor:
test:

---

## AI Rules

Prompt Version Controlled

All prompts stored in:

prompt_template

No hardcoded prompt in controller.

---

## Documentation Rules

Architecture changes require:

ER update
API update
Sprint update

---

## Code Review Rules

Required before merge:

Unit Test Pass
Code Review Pass
Build Pass

---

## Production Configuration Safety

Production starts with the `prod` profile:

```bash
SPRING_PROFILES_ACTIVE=prod java -jar zeroon-backend.jar
```

Before the application context is created, ZEROON rejects production startup
when any of the following are missing, too short, or still use a known
development/example value:

- `ZEROON_ACCESS_TOKEN_SECRET`: at least 32 characters;
- `POSTGRES_PASSWORD`: at least 12 characters;
- `ZEROON_LOCAL_VERIFICATION_CODE`: six non-default characters during the
  temporary pre-SMS stage.

The validator reports only the environment variable name and never logs its
value. Local and test profiles retain the documented development defaults.

The verification-code setting is temporary. Sprint 08 authentication work must
replace the production fixed-code path with a real sender, random one-time
codes, shared storage, throttling, and attempt limits before public release.

---

## MVP Principle

Simple First

No over-engineering

Deliver before optimize
