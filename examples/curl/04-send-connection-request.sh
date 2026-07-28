#!/usr/bin/env bash
# Send a LinkedIn connection request, optionally with a note.
# The server enforces the account's daily send limit, the note length cap
# (200 chars free / 300 premium) and a 21-day resend cooldown.
# Usage: ./04-send-connection-request.sh ln_ac_XXXXXXXXXXXX ACoAA_TARGET_URN "optional note"
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_API_BASE:-https://app.gtm-api.com/linkedin/v4}"

if [ $# -lt 2 ]; then
  echo "usage: $0 <linkedin_account_sid> <profile_id (ln_id or sn_id URN)> [note]" >&2
  exit 1
fi
ACCOUNT_SID="$1"
PROFILE_ID="$2"
NOTE="${3:-}"

if [ -n "$NOTE" ]; then NOTE_JSON="\"$NOTE\""; else NOTE_JSON=null; fi

curl -sS -X POST "$BASE/api/linkedin-connection-requests/send" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "linkedin_account_sid": "$ACCOUNT_SID",
  "profile_id": "$PROFILE_ID",
  "note": $NOTE_JSON
}
JSON
)"
