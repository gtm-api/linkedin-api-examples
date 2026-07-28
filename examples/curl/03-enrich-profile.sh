#!/usr/bin/env bash
# Enrich a LinkedIn profile from its vanity URL (the /in/... slug).
# Returns the lite profile: name, headline, location, current position, URNs.
# Usage: ./03-enrich-profile.sh [public_identifier]
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"
PUBLIC_IDENTIFIER="${1:-satyanadella}"

curl -sS -X POST "$BASE/api/linkedin-enrichment/person-lite-profile" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"public_identifier\": \"$PUBLIC_IDENTIFIER\", \"idempotency_key\": \"lite-profile-$PUBLIC_IDENTIFIER\"}"
