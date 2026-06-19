# Sprint 00 Plan V1

## Schedule

- Start: 2026-06-08
- End: 2026-06-12
- Goal: make Sprint 01 independently estimable, buildable, and testable.

## Work Items

| ID | Owner | Deliverable | Estimate |
|---|---|---|---|
| S0-01 | Architect | Flutter and modular-monolith ADRs | 0.5d |
| S0-02 | Architect | Authentication and authorization baseline | 0.5d |
| S0-03 | Backend | OpenAPI and initial Flyway migration | 1.0d |
| S0-04 | Backend | Spring Boot project skeleton | 0.5d |
| S0-05 | Mobile | Flutter project skeleton | 0.5d |
| S0-06 | Web | React admin project skeleton | 0.5d |
| S0-07 | DevOps | Docker Compose, environment template, CI | 0.5d |
| S0-08 | PM/Product | Sprint 01 backlog and interaction states | 1.0d |

## Exit Criteria

- OpenAPI parses and defines authentication, errors, pagination, and ownership-protected APIs.
- Database migration includes users, roles, refresh sessions, records, conversations, memory, prompts, and audit logs.
- Backend, mobile, and admin projects have standard build entry points.
- Docker Compose validates.
- CI contains backend, mobile, admin, and contract jobs.
- Sprint 01 tasks have owner, estimate, dependency, and acceptance criteria.

