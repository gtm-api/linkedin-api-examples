#!/usr/bin/env bash
# Search LinkedIn people with structured filters (no search URL needed).
# Runs through the platform executor pool unless you pass your own account sid.
# Usage: ./02-search-people.sh [keywords] [title]
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"
KEYWORDS="${1:-growth marketing}"
TITLE="${2:-}"

# Reuse the same idempotency_key when retrying a failed call: the ledger
# returns the stored outcome instead of executing (and charging) again.
IDEMPOTENCY_KEY="search-people-$(date +%s)"

if [ -n "$TITLE" ]; then TITLE_JSON="\"$TITLE\""; else TITLE_JSON=null; fi

curl -sS -X POST "$BASE/api/linkedin-scraping/search-people" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "filters": {
    "keywords": "$KEYWORDS",
    "title": $TITLE_JSON
  },
  "idempotency_key": "$IDEMPOTENCY_KEY"
}
JSON
)"
