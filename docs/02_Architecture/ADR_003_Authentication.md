# ADR-003: Authentication and Authorization

Status: Accepted

Date: 2026-06-07
Amended: 2026-07-24

## Decision

- Primary closed-Beta login: email address plus one-time verification code.
- Mobile-number endpoints remain as a disabled compatibility boundary.
  `ZEROON_SMS_ENABLED=false` is the default; disabled requests fail closed
  without calling a sender. Re-enabling SMS requires a separately reviewed
  provider and delivery acceptance.
- Email addresses are trimmed, lower-cased for identity lookup, unique, and
  private account identifiers. They are returned only to their authenticated
  owner through auth, `/me`, and the owned data export; they do not enter
  Companion prompts or Beta evidence.
- Existing mobile-only and email-only accounts are not automatically merged.
  This switch precedes the first external Beta invitation; any future account
  linking requires a separately reviewed proof-of-control flow.
- Access token: JWT, 30-minute default lifetime.
- Refresh token: opaque random token, 30-day lifetime, stored as a hash.
- Refresh tokens rotate on every refresh and can be revoked per device.
- Admin endpoints require the `ADMIN` role.
- Logout revokes the current refresh session.
- Account deletion follows the implemented synchronous hard-deletion contract
  in `Data_Control_Lifecycle_V1.md`.

## Security Baseline

- Verification codes expire after 10 minutes.
- Production uses a secure random six-digit generator and Redis-backed atomic
  one-time consumption. Local/test fixed codes and code logging are never
  active under `prod`.
- Email send rate: one request per address every 60 seconds, maximum five per
  address and twenty per source IP per hour.
- Verify rate: ten attempts per stable installation identifier and thirty per
  source IP per 15 minutes.
- Verify rate: maximum 5 failed attempts per code.
- Mobile obtains a random per-install identifier from secure storage; no
  shared hard-coded production device id is used.
- Redis keys digest the email, IP, and device subjects. Raw refresh tokens are
  never stored; verification codes are short-lived and deleted after success
  or the failed-attempt cap.
- Production fails startup without reviewed SMTP, shared Redis, database, and
  token configuration. SMTP connection, read, and write timeouts are bounded.
- Authentication and admin mutations generate audit events.
