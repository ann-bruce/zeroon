# ZEROON Durable Decision Index

Last reviewed: 2026-08-19

This file indexes accepted decisions that a new project chat must not
re-litigate without new evidence. Detailed rationale and acceptance criteria
remain in the linked source. Add a new entry when a durable decision is made;
do not paste chat transcripts here.

| ID | Durable decision | Canonical source | Status |
|---|---|---|---|
| D-001 | ZEROON remains a long-term companion and private memory system, not a narrow emotional tool, diary, therapy product, task manager, public social product, or generic AI chat. | `docs/07_Sprints/Roadmap_Information_Architecture_V2.md` | Active |
| D-002 | Mobile uses Flutter and the backend remains a Spring Boot modular monolith unless a separately accepted architecture decision supersedes them. | `docs/02_Architecture/ADR_001_Mobile_Flutter.md`; `docs/02_Architecture/ADR_002_Modular_Monolith.md` | Active |
| D-003 | Closed-Beta authentication uses production email verification; App users and administrator identities have separate authorization paths. | `docs/02_Architecture/ADR_003_Authentication.md`; `docs/05_Engineering/Development_Guide_V1.md` | Active |
| D-004 | Long-term Memory is user-owned, source-linked, visible, disableable, deletable, and excluded from AI context by default until explicitly permitted. | `docs/02_Architecture/ADR_004_Memory_V1.md` | Active |
| D-005 | Interaction language supports Follow System, Simplified Chinese, and English without translating or inferring from user-authored content. | `docs/02_Architecture/ADR_005_Language_Locale_V1.md` | Active |
| D-006 | Help and feedback use a private, trackable, human-operated support lifecycle with an honest email fallback and no continuous-coverage claim. | `docs/02_Architecture/ADR_006_Support_Request_Lifecycle_V1.md` | Active |
| D-007 | Closed-Beta evidence is explicit-consent, content-free, aggregate-only for administrators, and must never block core product actions. | `docs/02_Architecture/ADR_007_Beta_Evidence_Event_Lifecycle_V1.md` | Active |
| D-008 | Persona V2 is production-active through a recorded owner-risk exception; professional safety review is still required and rollback remains available. | `docs/06_AI/evaluation/Persona_V2_V1_1_Review_Summary.md` | Active with open gate |
| D-009 | Sprint 13 originally coupled the in-app continuity cue to later cohort and notification gates. | Superseded by `D-010` | Superseded by D-010 |
| D-010 | Sprint 13 established and owner-accepted an in-app, user-owned continuity cue together with Reset hierarchy and first-loop refinements; the Sprint is fully closed with no remaining validation or notification task. | `docs/07_Sprints/Sprint_13_Return_Loop_Foundation_And_Owner_Acceptance_V1.md` | Closed |
| D-011 | ZEROON will complete bounded reliability, ownership, clarity, privacy, and release-readiness work in Sprints 14-16, validate acquisition/activation/return/trust after production and App Store release in Sprint 17, select Sprint 18 from evidence, and keep the physical entitlement pilot gated as Sprint 19. | `docs/08_Roadmap/Sprint_14_19_Execution_Roadmap_V1.md` | Active roadmap |
| D-012 | Sprint 14 uses device-local, account-scoped, backup-excluded Reset drafts; stable per-intent idempotency replaces time-window content deduplication; deleting an owned Record hard-deletes its source-linked Memory and removes the Record from all live product and AI-context surfaces. | `docs/07_Sprints/Sprint_14_Record_Reliability_And_Ownership_V1.md` | Active |

## Change Rules

- Use a new ID when a new durable product, architecture, privacy, AI, release,
  or operating decision is accepted.
- Mark an old row `Superseded by D-xxx` instead of silently rewriting history.
- Keep implementation progress in the active Sprint, not in this index.
- Never record passwords, tokens, verification codes, private user content, or
  unreviewed production data.
