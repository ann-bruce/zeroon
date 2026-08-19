# ZEROON Current State
Last verified: 2026-08-19

This is the short, canonical entry point for a new Codex chat. Keep it factual,
current, and at most 100 lines. Historical detail belongs in Sprint documents,
ADRs, release reports, or the archived state file.

## Truth Order

When sources disagree, use this order and report the mismatch:

1. Current checkout facts: `git status`, `git log`, code, migrations, tests.
2. This file for the latest verified operating state and next gate.
3. The active Sprint document for scope and acceptance.
4. ADRs, OpenAPI, engineering guides, and release evidence.
5. Old chats and archived state documents only as historical clues.

Never infer deployment state from a local commit alone.

## Execution Snapshot

- Branch baseline: `main`
- Verified planning baseline commit: `ebfa839`
- Active Sprint: Sprint 14 — Record Reliability And Ownership
- Sprint status: started on 2026-08-19; `S14-01` draft, idempotency, and Record
  deletion contracts are accepted; implementation has not started
- Next gate: implement `S14-02` durable local Reset draft from
  `docs/07_Sprints/Sprint_14_Record_Reliability_And_Ownership_V1.md`

Run `scripts/zeroon-context.sh` at the start of every takeover. A different
HEAD or a dirty working tree is new evidence that must be inspected, not
silently folded into this snapshot.

## Runtime And Release Facts

- The backend has previously run on Alibaba Cloud with the production profile
  and email verification.
- The owner installed the iOS app and passed the core business regression.
- Android validation is explicitly deferred until after the iOS validation
  phase.
- Persona V2 is production-active through the recorded owner-risk exception;
  professional safety review remains pending.
- Local `main` does not prove which commit is deployed. Check the release
  runbook and the intended environment before any deployment claim.

Do not deploy, invite participants, activate prompts, change production data,
or send external communications without explicit user authorization.

## Latest Product Outcome

Sprint 13 delivered one quiet, private, user-owned continuity cue. The cue:

- uses only the authenticated user's eligible Record;
- does not classify private text or infer emotion, importance, or unfinished
  work;
- replaces the existing Now rhythm-card slot instead of adding page density;
- can be ignored or dismissed without penalty;
- never changes Memory or AI consent;
- keeps evidence content-free.

Owner acceptance passed. Broader acquisition, activation, return, retention,
and trust value remains unproven and is scheduled only after bounded
optimization and an explicitly authorized production/App Store release.

## Durable Guardrails

- ZEROON is a long-term companion and private memory system.
- Profile fields remain optional and private by default.
- Profile and Memory enter AI context only through their separate explicit
  consent controls.
- Memory stays visible, source-linked, disableable, and deletable.
- Paid value must come from continuity and control, not emotional closeness.
- Do not drift into therapy, diagnosis, scoring, streak pressure, task
  management, public identity, social feeds, or generic AI chat.

## Canonical Sources

- Latest closed Sprint: `docs/07_Sprints/Sprint_13_Return_Loop_Foundation_And_Owner_Acceptance_V1.md`
- Durable decision index: `DECISION_LOG.md`
- Product validation roadmap: `docs/08_Roadmap/ZEROON_90_Day_Product_Validation_Plan_V1.md`
- Product optimization and feature Backlog: `docs/08_Roadmap/ZEROON_Product_Backlog_V1.md`
- Sprint 14-19 execution roadmap: `docs/08_Roadmap/Sprint_14_19_Execution_Roadmap_V1.md`
- Release gate: `docs/05_Engineering/Closed_Beta_Launch_Runbook_V1.md`
- Persona V2 evidence:
  `docs/06_AI/evaluation/Persona_V2_V1_1_Review_Summary.md`
- API contract: `docs/04_API/OpenAPI_V1.yaml`
- Historical state through 2026-07-28:
  `docs/05_Engineering/Project_State_Archive_2026-07-28.md`

## Update Contract

Update this file only when a fact is verified. At minimum update:

- `Last verified`;
- verified product baseline commit;
- active Sprint and status;
- next decision or release gate;
- runtime facts only when runtime evidence exists.

Do not append completed-task narratives here; update the relevant Sprint, decision, or release document instead.
