# ZEROON Nginx TLS

`compose.yaml` mounts:

- `letsencrypt/config/` as Certbot's persistent certificate directory;
- `nginx/acme/` as the HTTP-01 challenge webroot.

The certificate and ACME working directories are ignored by Git. Never commit
private keys.

The certificate installed on `121.196.169.178` on 2026-07-26 is a publicly
trusted Let's Encrypt IP certificate using the `shortlived` profile. Nginx
reads it from `letsencrypt/config/live/zeroon-ip/`. The previous self-signed
certificate is no longer used. The app must not disable certificate
validation.

Let’s Encrypt IP certificates use the short-lived certificate profile and
require frequent automated renewal. Before requesting one with the HTTP-01
webroot flow, Alibaba Cloud must allow inbound TCP/80 from the public internet.
Keep that rule enabled so renewals can complete. Install
`renew-ip-certificate.sh` as a systemd service scheduled at least twice daily.

Validate and reload Nginx after a manual certificate change:

```bash
docker compose run --rm nginx nginx -t
docker compose restart nginx
```
