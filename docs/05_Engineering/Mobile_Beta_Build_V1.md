# ZEROON Mobile Beta Build V1

Status: Engineering scaffold ready; signing and store accounts remain external
Date: 2026-07-26

## Release identity

- App display name: `ZEROON`
- Android application ID: `ai.zeroon.app`
- iOS bundle ID: `ai.zeroon.app`
- First Beta version baseline: `1.0.0 (1)`

The identifiers can be changed before the first Play Console or App Store
Connect upload. After that first upload, treat them as immutable.

## Required public configuration

Release builds require:

- `ZEROON_API_BASE_URL`, using HTTPS and ending in `/api/v1`;
- `ZEROON_SUPPORT_EMAIL`, defaulting to `zeroon_ai@outlook.com`;
- `ZEROON_BUILD_NAME`;
- a positive integer `ZEROON_BUILD_NUMBER`.

Provider keys, SMTP credentials, database credentials, signing passwords, and
other secrets must never be passed through Dart defines or committed to the
repository.

The TLS certificate presented by the API must chain to a public trust anchor.
Merely using an `https://` URL is not sufficient. The current
`121.196.169.178` endpoint uses a publicly trusted Let's Encrypt IP
certificate. Keep automated renewal healthy and do not add a
certificate-validation bypass to the app.

## Verify

```bash
scripts/zeroon-mobile-build.sh verify
```

Local native prerequisites:

- Android SDK platform/build tools with the Google license accepted by the
  account holder;
- Xcode with an installed iOS platform;
- CocoaPods for plugins that do not yet support Swift Package Manager.

## Android

Create an upload keystore outside the repository. Copy
`mobile/android/key.properties.example` to
`mobile/android/key.properties`, then replace every example value. Both
`key.properties` and keystore files are ignored by Git.

```bash
ZEROON_API_BASE_URL=https://beta.example.com/api/v1 \
ZEROON_BUILD_NAME=1.0.0 \
ZEROON_BUILD_NUMBER=1 \
scripts/zeroon-mobile-build.sh android
```

The Play Console artifact is:

`mobile/build/app/outputs/bundle/release/app-release.aab`

Use `android-apk` only for explicitly approved direct-device testing.

## iOS

Register `ai.zeroon.app` in Apple Developer and App Store Connect, then make
the signing team available to Xcode:

```bash
ZEROON_API_BASE_URL=https://beta.example.com/api/v1 \
ZEROON_BUILD_NAME=1.0.0 \
ZEROON_BUILD_NUMBER=1 \
ZEROON_IOS_DEVELOPMENT_TEAM=YOUR_TEAM_ID \
scripts/zeroon-mobile-build.sh ios
```

Use `ios-unsigned` to validate compilation before signing is available. An
unsigned build cannot be distributed to Beta participants.

## Current Beta gate

As of 2026-07-26:

- Android release compilation passed and produced an unsigned AAB;
- iOS release compilation passed without code signing and produced
  `Runner.app`;
- `https://121.196.169.178/api/v1` is reachable through a publicly trusted
  Let's Encrypt IP certificate using the short-lived profile;
- the cloud backend is running with the `prod` profile, production SMTP and
  LLM configuration, rotated database/Redis credentials, and an internal
  health status of `UP`;
- a production email verification request returned `202`, and the Outlook
  mailbox receipt was confirmed;
- public TCP/80 remains required for automated IP-certificate renewal;
- Android upload signing, Apple signing, and real-device smoke tests remain
  pending.

The remaining release gates are signed artifacts and real-device smoke
testing. Android device testing is intentionally deferred until the first iOS
personal-device test passes.

## Release evidence

For every uploaded build, retain only non-secret evidence:

- Git commit;
- version and build number;
- artifact SHA-256;
- build result;
- TestFlight or Play testing-track status;
- device smoke result.

Never retain signing passwords, tokens, verification codes, private Record or
Memory content, or raw provider payloads.
