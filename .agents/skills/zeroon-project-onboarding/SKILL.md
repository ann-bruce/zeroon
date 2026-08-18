---
name: zeroon-project-onboarding
description: Take over the ZEROON repository from durable project evidence, reconcile current state with Git, and identify the next safe accepted action. Use when a new chat is asked to 接手 ZEROON, 核对仓库, 继续, 下一项, 下一阶段, review recent work, or resume the project without copying another chat's summary.
---

# Take Over ZEROON

Build context from the repository instead of reconstructing another chat.
Separate verified facts, dirty parallel work, documented intent, and unknown
runtime state.

## Takeover Workflow

1. Start at the ZEROON repository root.
2. Read `AGENTS.md` and `CURRENT_STATE.md`.
3. Run `scripts/zeroon-context.sh`.
4. Read `DECISION_LOG.md`.
5. Read only the active Sprint and canonical documents linked from
   `CURRENT_STATE.md` that are relevant to the request.
6. Compare the documented baseline with the current branch, HEAD, upstream
   divergence, recent commits, and staged, modified, and untracked files.
7. Inspect relevant diffs before attributing meaning to dirty files. Treat
   uncommitted work as belonging to another user or chat unless proven
   otherwise.
8. Report stale, contradictory, or unverifiable statements. Do not repair them
   silently.

## Establish The Next Action

For `继续`, `下一项`, or `下一阶段`:

- select the next unmet accepted gate from the active Sprint;
- prefer verification or owner validation when implementation is complete;
- do not activate a future candidate or invent missing Sprint scope;
- distinguish local implementation, committed code, pushed code, deployed
  code, runtime acceptance, and product validation.

Use the ZEROON product guardrail for product planning, the ZEROON development
workflow for code or service changes, and the ZEROON experience review for UI
or product-voice review.

## First Takeover Response

Before modifying files, provide a concise snapshot:

- branch and HEAD compared with the verified baseline;
- clean or dirty working-tree state, naming affected files;
- active Sprint and current accepted gate;
- next safe action;
- blockers or facts requiring runtime verification.

Do not claim that a new chat inherited another chat's reasoning. State that
context was rebuilt from repository evidence.

## Completion Discipline

- Preserve unrelated edits.
- Do not read or print `.env`, secrets, verification codes, private messages,
  Record content, Memory content, or production user data.
- Do not commit, push, deploy, invite participants, activate prompts, or change
  production state unless the user explicitly requests it.
- Update `CURRENT_STATE.md` only after the referenced fact is verified.
- Add a `DECISION_LOG.md` row only after a durable decision is accepted.
- Record implementation and acceptance detail in the active Sprint or release
  evidence document, not in `CURRENT_STATE.md`.
- Run validation proportionate to changes and report commands, results, service
  status, and remaining risk.
