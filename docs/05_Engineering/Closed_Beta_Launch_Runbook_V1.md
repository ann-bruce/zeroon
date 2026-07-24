# ZEROON Closed-Beta Launch Runbook V1

Status: Engineering-ready; external access gates pending
Date: 2026-07-23

## Release boundary

The first wave is at most 20 invited adults. Invitations remain paused until
every required row below is recorded with date, environment, operator, and
evidence reference. Local fixed codes, fake AI replies, synthetic users, and
written role assignments are not production-like acceptance.

## Required configuration

- `SPRING_PROFILES_ACTIVE=prod`
- a non-example JWT secret and PostgreSQL password
- production-like Redis
- reviewed SMTP verification-code sender configuration; SMS remains disabled
- `ZEROON_EVIDENCE_INGESTION_ENABLED=true`
- `ZEROON_EVIDENCE_NOTICE_VERSION=beta-evidence-v2`
- `ZEROON_EVIDENCE_RETENTION_DAYS` between 1 and 180
- reviewed LLM provider key and `ZEROON_LLM_MODEL`
- Flutter build argument
  `--dart-define=ZEROON_SUPPORT_EMAIL=zeroon_ai@outlook.com`
- reachable `zeroon_ai@outlook.com` handling path

Secrets, codes, tokens, prompts, participant content, and raw provider bodies
must not be copied into this runbook or acceptance evidence.

## Acceptance matrix

| Gate | Required proof | Current status |
|---|---|---|
| Adult bilingual notice | zh-CN and English render, under-18 path blocks, opt-in and opt-out both behave truthfully | Automated narrow-layout and local runtime pass |
| Consent sequence | Login succeeds, notice completes, current `AUTH_COMPLETED` is queued only after opt-in and before encounter; no backfill | Automated and local PostgreSQL runtime pass |
| Revocation | Profile switch stops new evidence immediately without disabling core product | Automated and local PostgreSQL runtime pass |
| Real verification code | Intended Beta SMTP sender delivers to domestic and international inboxes, code is consumed once, spam placement is reviewed, and rate limits/outage copy remain truthful | SMTP engineering complete; intended-environment delivery and outage smoke pending |
| Real AI provider | Approved model returns a normal response and bounded refusal/fallback without private logs | Production-like smoke pending |
| Cross-user isolation | User A cannot read or mutate User B Profile, Record, Memory, support, export, or evidence | Full automated gate plus runtime sample |
| Evidence event failure isolation | Event ingestion unavailable or throttled does not roll back login, encounter, Record, Memory control, export, or deletion; the adult-notice preference gate is not bypassed | Automated and local disabled-ingestion pass; production-like outage/throttle sample pending |
| Account deletion | `204`, account-owned private/evidence rows zero, refresh unusable | Local PostgreSQL pass; production-like sample pending |
| Primary support | Bruce Ann can receive and respond through mailbox and ADMIN queue | Access test pending |
| Backup support | Chao Fan can receive/respond through mailbox and authenticate to ADMIN queue with least privilege | Access test pending |

## Incident stop rule

Pause new invitations immediately when any of these is observed:

- verification codes cannot be delivered or are reusable;
- a successful Record is not durable or becomes visible to another user;
- account deletion reports success while owned private or evidence rows remain;
- Profile or Memory consent is ignored by an AI request;
- content appears in evidence, operational logs, or ADMIN aggregate responses;
- `zeroon_ai@outlook.com` or the in-app support route is unreachable;
- the primary and backup operator cannot access the handling path;
- a blocking safety, privacy, or data-isolation defect has no containment.

Existing participants receive a concise service-status explanation through the
approved support channel. Do not silently continue recruitment while a stop
condition is open. Resume only after the defect is fixed, regression tested,
and the accountable operator records the decision.

## First-wave operating rhythm

1. Invite no more than five participants.
2. Observe authentication, Record durability, support reachability, deletion,
   and content-free evidence health for at least one complete operating day.
3. Resolve blocking defects before inviting the next group.
4. Never change the product promise or event dictionary mid-cohort without a
   versioned decision and renewed notice where required.
5. Review aggregate evidence weekly; cells below five remain suppressed.
6. Expand toward 20 only after the first group is stable. Expansion beyond 20
   requires the documented stability review.

## Acceptance record

For each smoke, record:

- UTC and Asia/Shanghai date;
- environment and app version;
- operator;
- pass/fail and bounded reason code;
- non-secret log or test-report reference;
- cleanup result for synthetic accounts;
- stop/resume decision where relevant.

Never paste participant content, mobile numbers, tokens, verification codes,
provider credentials, or raw prompts into the record.
