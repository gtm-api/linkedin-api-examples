#!/usr/bin/env bash
# Hand someone a link to sign a LinkedIn account into its cloud browser.
# Every connected account runs in its own anti-detect browser behind a
# dedicated proxy; this mints a scoped, expiring link to that browser so
# the account owner can log in without a platform account of their own.
#
# The response carries access_key (shown once) and public_connect_url.
# That URL is a bearer secret: it grants remote browser access, so keep the
# TTL short, cap the connects, and send it over a private channel.
# Usage: ./10-cloud-browser-login-link.sh [ab_br_XXXXXXXXXXXX]
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

BROWSER_SID="${1:-}"

# No sid given: take the first browser on the team.
if [ -z "$BROWSER_SID" ]; then
  echo "no browser sid given, picking the first one on the team" >&2
  curl -sS -X POST "$BASE/api/antidetect-browsers/search" \
    -H "Authorization: Bearer $GTM_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"page_size": 1}'
  echo >&2
  echo "rerun with a sid from items[].item.sid above" >&2
  exit 0
fi

curl -sS -X POST "$BASE/api/antidetect-browsers/generate-cloud-browser-access-key" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "sid": "$BROWSER_SID",
  "ttl_hours": 4,
  "max_connects": 3
}
JSON
)"

# Optional scoping on the same call: "allowed_ips": ["203.0.113.10"] and
# "allowed_countries": ["DE"] are checked at connect time.
# Revoke early with POST /api/antidetect-browsers/revoke-cloud-browser-access-key
