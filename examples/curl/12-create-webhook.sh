#!/usr/bin/env bash
# Subscribe to events instead of polling: new replies, accepted invitations,
# account login trouble. Webhooks live on the orchestration service.
# The 32-char secret comes back ONCE in this response and is masked on every
# later read, so store it now: you need it to verify delivery signatures.
# Usage: ./12-create-webhook.sh https://example.com/hooks/gtm
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_ORCHESTRATION_BASE:-https://app.gtm-api.com/orchestration/v4}"

TARGET_URL="${1:-}"
if [ -z "$TARGET_URL" ]; then
  echo "usage: $0 <https target_url>" >&2
  exit 1
fi

# target_url must be https and resolve to a public address.
curl -sS -X POST "$BASE/api/webhooks" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "name": "Inbox and invitations",
  "target_url": "$TARGET_URL",
  "events": [
    "linkedin-messages.received",
    "linkedin-connection-requests.accepted",
    "linkedin-accounts.login-failed"
  ]
}
JSON
)"

# Send yourself a sample delivery: POST /api/webhooks/{sid}/test
# Narrow to one account at creation time with:
#   "filters": { "account_sid": "ln_ac_XXXXXXXXXXXX" }
# Verifying delivery signatures: verifyWebhookSignature() at the bottom of
# examples/typescript/12-create-webhook.ts.
