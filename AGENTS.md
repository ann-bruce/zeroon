# AGENTS.md

This file gives Codex the project context needed to work in this repository without repeatedly rediscovering conventions.

## Project

ZEROON is an original IP and digital product around long-term AI companionship.

Product areas:
- `mobile/`: Flutter app for state tracking, Zero Record, AI companion, and memory timeline.
- `admin/`: React + Vite + Ant Design admin system.
- `backend/`: Spring Boot backend for auth, state, records, companion, and memory services.
- `deployment/`: Docker Compose infrastructure for PostgreSQL and Redis.
- `docs/`: Product, architecture, database, API, engineering, AI, and sprint documentation.

Primary development path:

```text
/Users/bruceann/codexspace/zeroon/ZEROON_PROJECT/10_TECH/zeroon
```

## First Checks

Before editing:
- Run `git status --short` from this directory and preserve user changes.
- Run `scripts/zeroon-context.sh` for a bounded repository snapshot.
- Read `CURRENT_STATE.md`, then follow only its active-Sprint and decision links
  relevant to the request.
- Read the relevant source and matching docs before changing behavior.
- Prefer `rg` and `rg --files` for search.

Canonical docs:
- Current state handoff: `CURRENT_STATE.md`
- Durable decision index: `DECISION_LOG.md`
- API contract: `docs/04_API/OpenAPI_V1.yaml`
- REST notes: `docs/04_API/REST_API_V1.md`
- Database model: `docs/03_Database/ER_Model_V1.md`
- Engineering guide: `docs/05_Engineering/Development_Guide_V1.md`
- Done criteria: `docs/05_Engineering/Definition_of_Ready_Done.md`
- Sprint scope and acceptance notes: `docs/07_Sprints/`

## New Chat Takeover

Use the repository skill
`.agents/skills/zeroon-project-onboarding/SKILL.md` when the user asks to take
over ZEROON, check the repository, continue, or start the next item.

Treat repository evidence as authoritative over old chat summaries. A new chat
must:

- compare `CURRENT_STATE.md` with HEAD, recent commits, and the working tree;
- report stale or conflicting state instead of guessing;
- preserve all dirty files until their ownership and intent are understood;
- identify the next accepted gate from the active Sprint rather than inventing
  a later Sprint;
- avoid reading or printing `.env`, secrets, verification codes, or private
  user content.

When a verified change advances the active Sprint, release state, or production
state, update `CURRENT_STATE.md` in the same scoped change. Add to
`DECISION_LOG.md` only for a durable accepted decision.

## Commands

Backend:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew test
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew bootRun --args='--spring.profiles.active=local'
```

Mobile:

```bash
cd mobile
flutter analyze
flutter test
```

Admin:

```bash
cd admin
npm run lint
npm run build
```

Infrastructure:

```bash
cp .env.example .env
docker compose --env-file .env -f deployment/compose.yaml up -d
```

Workflow shortcuts:

```bash
scripts/zeroon-snapshot.sh
scripts/zeroon-service.sh status all
scripts/zeroon-service.sh start all
scripts/zeroon-service.sh restart mobile
scripts/zeroon-verify.sh quick
scripts/zeroon-verify.sh all
```

## Backend Conventions

- Java toolchain target is 21; local commands may use the configured Corretto 17 path when Gradle toolchains handle Java 21.
- Spring Boot version is managed in `backend/build.gradle`.
- Public APIs use `/api/v1`.
- Successful responses return resource schemas and appropriate HTTP status codes.
- Errors should be RFC 9457-compatible `application/problem+json`.
- Persisted database names use `snake_case`.
- Use Flyway migrations for database changes under `backend/src/main/resources/db/migration/`.
- Do not hardcode AI prompts in controllers. Prompt templates belong in versioned storage or a prompt template layer.

## Mobile Conventions

- Flutter app uses Riverpod, GoRouter, and Dio.
- Keep feature code grouped under `mobile/lib/<feature>/`.
- Shared API and design helpers live under `mobile/lib/common/`.
- When backend API payloads change, update mobile models, repositories, and tests together.

## Admin Conventions

- React app uses Vite and Ant Design.
- Keep UI changes consistent with existing `admin/src` structure and styles.
- Run both lint and build for admin behavior changes when dependencies are available.

## Documentation Rules

When behavior changes cross module boundaries:
- Update `docs/04_API/OpenAPI_V1.yaml` for API shape changes.
- Update database docs or migrations for persistence changes.
- Update sprint or acceptance docs when completing scoped sprint work.

When a Sprint or Backlog item starts, completes, closes, becomes blocked, or
unblocks another item, update the complete status chain in the same scoped
change:

- `CURRENT_STATE.md` for the active Sprint and next gate;
- the affected Sprint plan and dependent future Sprint statuses;
- `DECISION_LOG.md` when a durable decision is accepted, implemented,
  superseded, or closed;
- `docs/08_Roadmap/ZEROON_Product_Backlog_V1.md` for item delivery state;
- `docs/08_Roadmap/Sprint_14_19_Execution_Roadmap_V1.md` and the 90-day plan
  when sequence or dependency state changes;
- any other canonical roadmap or information-architecture index that repeats
  the changed status.

Before reporting the status update complete, use `rg` to find stale references
to the old Sprint, dependency, blocking condition, or Backlog state and run
`git diff --check`. A partial status update is not complete.

Definition of done for non-trivial changes:
- Implementation and migrations are present.
- Relevant unit or integration tests pass.
- API documentation is updated.
- Authorization and ownership behavior is covered where applicable.
- Logs do not expose secrets or private message content.

## Git And Safety

- The repository may contain user edits. Never revert changes you did not make unless explicitly asked.
- Keep changes scoped to the requested task.
- Use conventional commit prefixes when committing: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Main workflow branches are `feature/*`, `develop`, `release/*`, `main`, and `hotfix/*`.
