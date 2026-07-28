#!/usr/bin/env bash
# Read the inbox: newest conversations for an account, each with its last
# messages attached. These are local reads of synced data, so they cost
# nothing and hit no LinkedIn page.
# Usage: ./09-read-inbox.sh ln_ac_XXXXXXXXXXXX
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

if [ $# -lt 1 ]; then
  echo "usage: $0 <linkedin_account_sid>" >&2
  exit 1
fi
ACCOUNT_SID="$1"

curl -sS -X POST "$BASE/api/linkedin-conversations/search" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "filter": { "linkedin_account_sid": { "eq": "$ACCOUNT_SID" } },
  "sort": { "field": "last_activity_at", "direction": "desc" },
  "include": ["last_messages"],
  "page_size": 20
}
JSON
)"

# Read pagination.next_cursor from the response and send it back as
# "cursor" for the next page. null means you reached the end.
