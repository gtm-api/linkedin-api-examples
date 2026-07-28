#!/usr/bin/env bash
# Send a LinkedIn direct message to a profile URN (starts a new thread).
# To reply in an existing thread, send linkedin_conversation_sid (ln_cv_...)
# instead of ln_id.
# Usage: ./05-send-message.sh ln_ac_XXXXXXXXXXXX ACoAA_TARGET_URN "message text"
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

if [ $# -lt 3 ]; then
  echo "usage: $0 <linkedin_account_sid> <ln_id URN> <text>" >&2
  exit 1
fi
ACCOUNT_SID="$1"
LN_ID="$2"
TEXT="$3"

curl -sS -X POST "$BASE/api/linkedin-messages/send" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "linkedin_account_sid": "$ACCOUNT_SID",
  "ln_id": "$LN_ID",
  "text": "$TEXT"
}
JSON
)"
