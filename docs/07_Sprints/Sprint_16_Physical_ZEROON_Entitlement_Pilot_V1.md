# Sprint 16 Physical ZEROON Entitlement Pilot V1

Status: Candidate; deferred until entry gates pass
Prepared: 2026-07-31

Sprint 16 is a reserved future candidate. This document does not approve,
define, or reorder Sprint 14 or Sprint 15, and it does not move broader V2
hardware work into the current validation period.

## Intake Decision

### 1. Mainline fit

A physical ZEROON can extend an established digital companion into the user's
physical space. The experiment is relevant only if users understand the object
as a calm expression of continuity and companionship.

It is not evidence that the app's memory and return loop works, and it must not
replace validation of the digital product.

### 2. Drift risk

The pilot must not become:

- a login, streak, Record-count, emotion, or disclosure reward;
- a countdown, scarcity campaign, loot mechanic, or engagement incentive;
- a store, public sale, crowdfunding promise, or mass-delivery commitment;
- a gift, couple, confession, social, or referral feature;
- a reason to collect government identity, device fingerprints, or unrelated
  private product data;
- a promise of BLE, NFC, Emotion Light, or smart-device capability.

The product surface should use `申请实体 ZEROON` or
`让 ZEROON 来到身边`, not reward-oriented `领取` copy.

### 3. Recommended abstract capability

**Controlled physical-companion entitlement**: an approved participant receives
one explicit entitlement for one physical ZEROON campaign. The participant may
apply once, retry safely, inspect fulfillment status, or decline without
affecting the digital product.

### 4. Roadmap decision

Reserve Sprint 16 as **Physical ZEROON Entitlement Pilot**.

The sprint remains a candidate until all entry gates below pass. Initial scope
is a limited physical-companion and fulfillment experiment, not smart hardware.

### 5. Planning acceptance criteria

The sprint may enter implementation only if:

- Sprint 13 has a recorded `Continue` or bounded `Reshape` decision;
- no open trust, privacy, support, deletion, or cross-user isolation blocker
  exists;
- at least one physical sample and 3-5 supplier quotations have been reviewed;
- the owner approves quantity, budget, delivery region, replacement policy,
  and accountable fulfillment operator;
- collection, encryption, retention, deletion, and operator access for delivery
  data have a reviewed policy;
- the pilot does not claim that physical-item interest proves app retention.

## Sprint Goal

Determine whether a small, approved group experiences one physical ZEROON as a
meaningful extension of the existing companion, while proving that eligibility,
claiming, delivery, and deletion can be operated without duplicate fulfillment
or unnecessary identity collection.

## Pilot Boundary

- One campaign and one physical design.
- One approved entitlement per participant account for the campaign.
- Initial pilot size: 5-20 approved adults.
- Eligibility is assigned manually and is never derived from product activity
  or private content.
- Multiple approved people may share an address. Address equality is a manual
  review signal, never an automatic duplicate decision.
- A cancelled or lost shipment restores eligibility only through an audited
  operator decision.

## Proposed Domain Model

### `physical_zeroon_campaign`

- stable campaign id and public name;
- application window and quantity cap;
- lifecycle status;
- no urgency or countdown mechanics in the user experience.

### `physical_zeroon_entitlement`

- campaign id;
- user id;
- optional hashed single-use invitation token;
- status and expiry;
- grant and claim timestamps;
- unique `(campaign_id, user_id)`;
- unique invitation-token hash where present.

### `physical_zeroon_claim`

- entitlement id and user id;
- stable idempotency key;
- fulfillment status;
- created, updated, shipped, and delivered timestamps;
- external fulfillment reference where needed;
- unique `entitlement_id`;
- unique `(user_id, idempotency_key)`.

### `physical_zeroon_delivery`

- claim id;
- encrypted recipient, contact, and delivery address;
- minimum fields required by the selected carrier;
- retention deadline and deletion timestamp;
- no Record, Memory, state, profile context, AI output, or evidence payload.

## Lifecycle

```text
ELIGIBLE
  -> CLAIMED
  -> ADDRESS_CONFIRMED
  -> FULFILLING
  -> SHIPPED
  -> DELIVERED
```

Exceptional states:

- `DECLINED`;
- `CANCELLED`;
- `DELIVERY_FAILED`;
- `REPLACEMENT_REVIEW`.

Retries return the existing claim. They never create another shipment.

## Proposed Interfaces

- `GET /api/v1/me/physical-zeroon-entitlements/current`
- `POST /api/v1/me/physical-zeroon-claims`
- `GET /api/v1/me/physical-zeroon-claims/{claimId}`
- owner-scoped delivery create/update/delete endpoints;
- ADMIN campaign, entitlement, fulfillment, and audited replacement actions.

Claim creation requires a stable `Idempotency-Key`. A repeated request returns
the original claim. Database uniqueness remains authoritative under concurrent
requests.

## Planned Work

| ID | Task | Surfaces | Done when |
|---|---|---|---|
| S16-01 | Freeze pilot and fulfillment rules | product, operations, privacy | Quantity, eligibility, cancellation, replacement, retention, and stop rules are approved |
| S16-02 | Add campaign and entitlement domain | backend, database, OpenAPI, tests | One user can hold at most one entitlement per campaign |
| S16-03 | Add idempotent claim flow | backend, OpenAPI, tests | Retries and concurrent requests return one claim and cannot create duplicate fulfillment |
| S16-04 | Add restrained user application surface | mobile, localization, tests | Eligible users can apply, decline, and view status without reward pressure |
| S16-05 | Add bounded fulfillment operations | admin, backend, audit, tests | Approved operators can fulfill and review exceptions without private product access |
| S16-06 | Add delivery-data controls | encryption, retention, export/delete decision, tests | Delivery data is minimal, access-controlled, expiring, and independently deletable |
| S16-07 | Run controlled pilot | operations, research, evidence | 5-20 approved adults complete fulfillment and provide content-free feedback |

## Non-Goals

- payment, store, marketplace, gifting, referrals, or public ordering;
- rankings, points, streaks, tasks, badges, scarcity pressure, or rewards;
- BLE, NFC, smart light, firmware, pairing, or device telemetry;
- identity-document collection or device fingerprinting;
- access to Record, Memory, AI conversation, state, or profile content;
- mass manufacturing, crowdfunding, or public delivery promises.

## Acceptance Criteria

- one participant account can create at most one claim for the campaign;
- duplicate taps, retries, concurrent requests, and app restarts resolve to the
  same claim;
- a second account cannot reuse an already-bound single-use entitlement;
- shared household addresses are not automatically rejected;
- cancelled and replacement states require an audited operator decision;
- eligibility never depends on activity, emotional disclosure, Record count,
  AI inference, or payment;
- delivery information is encrypted, access-audited, retained only for the
  approved period, and excluded from AI and product evidence;
- users can decline without losing access or seeing pressure copy;
- the pilot can be stopped without changing the meaning or availability of
  existing digital ZEROON data.

## Stop Rules

Pause new applications and fulfillment when:

- more than one shipment can be created from one entitlement;
- an unauthorized user can read or alter another user's claim;
- private product content enters delivery or fulfillment systems;
- delivery information is accessible outside the approved operator boundary;
- replacement or cancellation can bypass the entitlement limit;
- the physical item is marketed as a reward for disclosure, activity, or
  emotional dependency;
- supply, safety, quality, or support issues have no accountable containment.
