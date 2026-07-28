#!/usr/bin/env bash
# Bulk outreach in two phases: preview the plan, then commit it.
# Nothing bulk ever fires from a single call. The preview validates
# everything, charges nothing, and mints a commit_token; the commit spends
# that token. Mass actions live on the orchestration service, so the base
# URL differs from the LinkedIn endpoints.
# Usage: ./11-mass-action-preview-commit.sh ln_ac_XXXXXXXXXXXX ACoAA_TARGET_URN
set -euo pipefail
: "${GTM_API_KEY:?export GTM_API_KEY=gtm_live_YOUR_KEY first}"
BASE="${GTM_ORCHESTRATION_BASE:-https://app.gtm-api.com/orchestration/v4}"

if [ $# -lt 2 ]; then
  echo "usage: $0 <linkedin_account_sid> <profile_id> [more profile_ids...]" >&2
  exit 1
fi
ACCOUNT_SID="$1"
shift

# Build one target per profile id. Up to 100 items per run.
TARGETS=""
for PROFILE_ID in "$@"; do
  [ -n "$TARGETS" ] && TARGETS="$TARGETS,"
  TARGETS="$TARGETS{\"linkedin_account_sid\": \"$ACCOUNT_SID\", \"profile_id\": \"$PROFILE_ID\"}"
done

PLAN=$(cat <<JSON
{
  "title": "API demo batch",
  "target_entity": "linkedin-connection-requests",
  "scope": { "kind": "targets", "targets": [$TARGETS] },
  "plan": {
    "steps": [
      {
        "tool": "linkedin-connection-requests.send-linkedin-connection-request",
        "args": { "note": "Hi, enjoyed your post on pipeline reviews." }
      }
    ]
  },
  "schedule": { "interval_seconds_min": 120, "interval_seconds_max": 600 },
  "canary_mode": "first_item"
}
JSON
)

echo "--- preview" >&2
PREVIEW=$(curl -sS -X POST "$BASE/api/mass-actions/preview" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PLAN")
echo "$PREVIEW"

# The token is an HMAC over these exact inputs and the caller: edit anything
# and the commit fails, wait past 15 minutes and it expires. Re-preview in
# either case. Requires jq to read the token out of the response.
COMMIT_TOKEN=$(printf '%s' "$PREVIEW" | jq -r '.result.commit_token // empty')
if [ -z "$COMMIT_TOKEN" ]; then
  echo "no commit_token in the preview response, stopping" >&2
  exit 1
fi

echo "--- commit" >&2
printf '%s' "$PLAN" \
  | jq --arg t "$COMMIT_TOKEN" '. + {commit_token: $t}' \
  | curl -sS -X POST "$BASE/api/mass-actions" \
      -H "Authorization: Bearer $GTM_API_KEY" \
      -H "Content-Type: application/json" \
      -d @-

# The run is asynchronous even for one item; the returned sid is your handle.
# Monitor: GET /api/mass-actions/{sid}?include[]=metrics
# Control:  POST /api/mass-actions/{sid}/pause | /resume
# With canary_mode first_item, a failing first send pauses the whole run.
