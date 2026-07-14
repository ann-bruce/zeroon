# Sprint 08 Trust Foundation V1

Status: Ready for implementation  
Prepared: 2026-07-14  

## Implementation Status

| Item | Status | Evidence |
|---|---|---|
| S8-01 Administrator authorization | Completed | Database role mapping, signed-token roles, ADMIN route guard, migration V8, USER/ADMIN tests, local USER 403 |
| S8-02 Production configuration fail-fast | Completed | Focused tests and real unsafe-prod boot prove JWT, database, and fixed verification-code defaults are rejected before context creation |
| S8-03 Verification-code environment boundary | Pending | Not started |
| S8-04 AI profile consent closure | Pending | Not started |
| S8-05 Data-control and contract alignment | Pending | Not started |

## Sprint Goal

Close the highest-risk gaps between ZEROON's private-companion promise and its
actual production behavior.

This sprint does not add new user-facing growth mechanics. It establishes the
authorization, configuration, authentication, consent, and data-control
foundation required before controllable memory, real-AI expansion, closed beta,
or payment.

## Product Decision

### Mainline fit

Trust is a product capability. A private memory companion cannot claim
continuity when administrator access, secrets, verification, AI context, or
data exit behavior is ambiguous.

### Drift risk

- Do not expose provider/model settings as the center of the user product.
- Do not collect more personal data merely because production auth needs work.
- Do not use admin access as an unrestricted private-content browser.
- Do not ship a visible permission switch that has no behavior.

### Abstract capability

The sprint builds **verifiable user control**: identities and operators have
bounded authority, unsafe production configuration cannot start, and AI uses
only explicitly allowed context.

### Roadmap decision

Accept now. This sprint precedes Memory V1 and the real-provider acceptance
sprint.

## Scope and Sequence

### S8-01 Administrator authorization

Affected surfaces:

- backend user roles, token/principal authorities, security configuration;
- admin endpoints and tests;
- database seed/role operations if required;
- OpenAPI security descriptions;
- admin login assumptions and operations documentation.

Acceptance:

- a normal user receives 403 for every `/api/v1/admin/**` endpoint;
- an explicit ADMIN identity receives the intended response;
- admin access does not rely on manually editing a client token;
- an auditable actor identifier is available for future mutations;
- no private record or message body is exposed by this work.

### S8-02 Production configuration fail-fast

Affected surfaces:

- backend configuration and production profile;
- tests and deployment documentation;
- `.env.example` without real secrets.

Acceptance:

- production startup fails on the development JWT secret, default database
  password, fixed verification code, or other unsafe required configuration;
- local and test profiles remain convenient and explicit;
- secret values never appear in logs or committed files.

### S8-03 Verification-code environment boundary

Affected surfaces:

- auth service/sender/storage;
- Redis or production sender integration boundary;
- API rate-limit error behavior and tests;
- OpenAPI and operations documentation.

Acceptance:

- fixed `000000` and code logging are local-only;
- production uses random, expiring, one-time codes;
- mobile, device, and IP throttling decisions are documented and tested;
- failed-attempt limits exist;
- multi-instance state is not process-local in production.

Actual SMS-provider procurement can remain separately blocked if the interface,
environment boundary, and release failure behavior are complete.

### S8-04 AI profile consent closure

Affected surfaces:

- profile repository/service;
- companion context assembly;
- AI provider request tests;
- privacy copy and documentation.

Acceptance:

- permission off means no profile field reaches an AI provider request;
- permission on includes only the documented user-provided fields;
- disabling permission affects subsequent requests immediately;
- tests use a capturing fake provider and never log prompt content;
- no inferred personality label is persisted.

### S8-05 Data-control and contract alignment

Affected surfaces:

- current-user, export, deletion, and logout APIs;
- OpenAPI and mobile settings entry;
- deletion lifecycle and operations documentation;
- tests for ownership and idempotency.

Acceptance:

- OpenAPI clearly separates implemented and planned behavior;
- minimum beta export/delete behavior has an explicit product decision;
- no endpoint claims successful deletion while leaving undocumented retained
  user content;
- users can find the exit path without entering AI chat.

## Out of Scope

- Memory V1 implementation;
- embeddings, vector search, or RAG;
- monthly/yearly reflection;
- public sharing or community;
- subscription checkout;
- smart plush or Emotion Light;
- broad admin analytics dashboard.

## Engineering Rules

- Preserve the current Sprint 06 worktree.
- Update migration, test schema, OpenAPI, backend, mobile/admin client behavior,
  tests, and docs together when a contract changes.
- Keep the backend a modular monolith.
- Do not put raw private content into logs, analytics, audit payloads, or tests.
- Do not commit or push without explicit instruction.

## Verification

Minimum gate:

```bash
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home \
  scripts/zeroon-verify.sh all
```

Focused security evidence must also show:

- USER -> admin 403;
- ADMIN -> intended admin response;
- unsafe production configuration -> startup failure;
- profile consent off/on -> captured provider context excludes/includes only
  allowed fields;
- verification throttling and attempt behavior;
- data-control ownership and repeat-request behavior.

## Sprint Exit

- S8-01 through S8-05 have implementation and validation evidence, or an item
  explicitly blocks release with a documented external dependency.
- Full quality gate passes.
- Local services are running current code.
- The baseline blocker matrix is updated.
- Memory V1 can begin without inheriting ambiguous identity, consent, or exit
  behavior.
