#!/usr/bin/env bash
# List the LinkedIn accounts connected to your team.
# Usage: GTM_API_KEY=gtm_live_... ./01-list-linkedin-accounts.sh
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

curl -sS -X POST "$BASE/api/linkedin-accounts/search" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"page_size": 10}'
