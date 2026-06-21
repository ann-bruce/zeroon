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
- Read the relevant source and matching docs before changing behavior.
- Prefer `rg` and `rg --files` for search.

Canonical docs:
- API contract: `docs/04_API/OpenAPI_V1.yaml`
- REST notes: `docs/04_API/REST_API_V1.md`
- Database model: `docs/03_Database/ER_Model_V1.md`
- Engineering guide: `docs/05_Engineering/Development_Guide_V1.md`
- Done criteria: `docs/05_Engineering/Definition_of_Ready_Done.md`
- Sprint scope and acceptance notes: `docs/07_Sprints/`

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

