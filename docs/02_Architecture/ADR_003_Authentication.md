# ADR-003: Authentication and Authorization

Status: Accepted

Date: 2026-06-07

## Decision

- Primary login: mobile number plus one-time verification code.
- Access token: JWT, 15-minute lifetime.
- Refresh token: opaque random token, 30-day lifetime, stored as a hash.
- Refresh tokens rotate on every refresh and can be revoked per device.
- Admin endpoints require the `ADMIN` role.
- Logout revokes the current refresh session.
- Account deletion starts a 7-day recoverable period, followed by irreversible deletion or anonymization according to the data-retention policy.

## Security Baseline

- Verification codes expire after 5 minutes.
- Send rate: one request per 60 seconds, maximum 10 per mobile number per day.
- Verify rate: maximum 5 failed attempts per code.
- Raw verification codes and refresh tokens are never stored.
- Authentication and admin mutations generate audit events.

