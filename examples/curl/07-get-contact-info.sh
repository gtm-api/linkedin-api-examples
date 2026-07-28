#!/usr/bin/env bash
# Pull the contact details a profile exposes: emails, phones, websites, socials.
# Sub-record calls dispatch on a URN, so a slug-only target needs
# person-lite-profile first (see 03) or comes back not_dispatchable.
# Usage: ./07-get-contact-info.sh ACoAA_TARGET_URN
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

if [ $# -lt 1 ]; then
  echo "usage: $0 <profile_id (ln_id or sn_id URN)>" >&2
  exit 1
fi
PROFILE_ID="$1"

curl -sS -X POST "$BASE/api/linkedin-enrichment/person-contact-info" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"profile_id\": \"$PROFILE_ID\", \"idempotency_key\": \"contact-info-$PROFILE_ID\"}"
