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

## MVP Principle

Simple First

No over-engineering

Deliver before optimize
