#!/usr/bin/env bash
# Run a LinkedIn people search you already built in the UI: paste its URL.
# One page per call; pass a page number to walk deeper.
# Usage: ./06-search-people-by-url.sh "https://www.linkedin.com/search/results/people/?keywords=cto" [page]
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

URL="${1:-https://www.linkedin.com/search/results/people/?keywords=cto}"
PAGE="${2:-1}"

# The URL must start with https://www.linkedin.com/search/results/people/
# Anything else is refused with 422 invalid_search_url.
curl -sS -X POST "$BASE/api/linkedin-scraping/search-people-by-url" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"$URL\", \"page\": $PAGE, \"idempotency_key\": \"search-url-p$PAGE\"}"
