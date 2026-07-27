# ZEROON Mobile

Flutter client for ZEROON Web, Android, and iOS.

Use the repository-level build entrypoint:

```bash
scripts/zeroon-mobile-build.sh verify
```

Release builds require an HTTPS API URL ending in `/api/v1`. Android upload
keys, Apple signing configuration, and all credential files remain local and
must not be committed.

See
[`Mobile_Beta_Build_V1.md`](../docs/05_Engineering/Mobile_Beta_Build_V1.md)
for signed AAB and IPA instructions.
