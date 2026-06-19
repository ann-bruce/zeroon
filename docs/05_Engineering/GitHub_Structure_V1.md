# GitHub Structure V1

## Repository

zeroon/

---

## Directory Structure

mobile/

admin/

backend/

docs/
├── 01_PRD/
├── 02_Architecture/
├── 03_Database/
├── 04_API/
├── 05_Engineering/
├── 06_AI/
└── 07_Sprints/

deployment/
└── compose.yaml

assets/
├── logo/
├── character/
└── brand/

---

## Branch Strategy

main
develop
feature/*

release/*
hotfix/*

---

## Commit Convention

feat:
fix:
refactor:
docs:
test:
chore:

Example:

feat(user): add login api
fix(state): fix state history query

---

## Pull Request

Rules:

1. Feature Branch -> Develop
2. Develop -> Main
3. Code Review Required
4. CI Must Pass

---

## CI/CD

GitHub Actions

Pipeline:

Build
 -> Test
 -> Package
 -> Deploy

---

## Tech Stack

Mobile:
Flutter

Admin:
React

Backend:
Spring Boot

Database:
PostgreSQL

Cache:
Redis

AI:
Spring AI

---

## Documentation Rules

All design documents must be stored under:

docs/

No business logic documentation outside docs.

Architecture changes require documentation updates.
