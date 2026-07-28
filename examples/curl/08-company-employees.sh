#!/usr/bin/env bash
# List the employees of a company, one page per call.
# Target the company by its LinkedIn URL or by its numeric id, not both.
# Usage: ./08-company-employees.sh "https://www.linkedin.com/company/stripe/" [page]
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

COMPANY_URL="${1:-https://www.linkedin.com/company/stripe/}"
PAGE="${2:-1}"

curl -sS -X POST "$BASE/api/linkedin-scraping/company-employees" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "company": { "company_url": "$COMPANY_URL" },
  "page": $PAGE,
  "idempotency_key": "company-employees-p$PAGE"
}
JSON
)"
