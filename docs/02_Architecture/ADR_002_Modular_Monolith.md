# ADR-002: Backend Architecture

Status: Accepted

Date: 2026-06-07

## Decision

The MVP backend is a modular Spring Boot monolith. It exposes `/api/v1` directly behind Nginx or the cloud load balancer. No independent API Gateway is introduced.

Modules:

- auth
- user
- state
- record
- companion
- memory
- admin
- common

## Rules

- Modules communicate through application services, not another module's repository.
- All user-owned queries include the authenticated user ID.
- External LLM and SMS providers are accessed through adapter interfaces.
- Redis is optional infrastructure for verification-code throttling, token revocation, and caching.

## Consequences

This reduces deployment and observability overhead while preserving boundaries that can be extracted later.

