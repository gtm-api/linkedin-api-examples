// Bulk outreach in two phases: preview the plan, then commit it.
// Nothing bulk ever fires from a single call. The preview validates
// everything, charges nothing, and mints a commit_token; the commit spends it.
// Run: npx tsx examples/typescript/11-mass-action-preview-commit.ts ln_ac_XXXX ACoAA_URN ACoAA_URN2
import { gtmOrchestration, type Envelope } from "./client.ts";

const [accountSid, ...profileIds] = process.argv.slice(2);
if (!accountSid || profileIds.length === 0) {
  console.error("usage: 11-mass-action-preview-commit.ts <linkedin_account_sid> <profile_id...>");
  process.exit(1);
}

// Up to 100 items per run.
const plan = {
  title: "API demo batch",
  target_entity: "linkedin-connection-requests",
  scope: {
    kind: "targets",
    targets: profileIds.map((profileId) => ({
      linkedin_account_sid: accountSid,
      profile_id: profileId,
    })),
  },
  plan: {
    steps: [
      {
        tool: "linkedin-connection-requests.send-linkedin-connection-request",
        args: { note: "Hi, enjoyed your post on pipeline reviews." },
      },
    ],
  },
  // A send-class plan must carry a schedule: the gap between items is
  // randomized inside this range, because a fixed cadence is itself a pattern.
  schedule: { interval_seconds_min: 120, interval_seconds_max: 600 },
  // Only item 1 dispatches until it succeeds, so a broken template costs one
  // send instead of a hundred.
  canary_mode: "first_item",
};

interface PreviewEnvelope extends Envelope {
  result: {
    commit_token: string;
    expires_at: string;
    preview: { items_count: number; credits_estimate: number; [key: string]: unknown };
  };
}

const preview = await gtmOrchestration<PreviewEnvelope>("/api/mass-actions/preview", plan);
console.log("preview:", JSON.stringify(preview.result.preview, null, 2));

// The token is an HMAC over these exact inputs and the caller: edit anything
// and the commit fails, wait past 15 minutes and it expires. Re-preview in
// either case. A still-valid token replays into a second identical run, so
// discard it the moment the commit succeeds.
const run = await gtmOrchestration("/api/mass-actions", {
  ...plan,
  commit_token: preview.result.commit_token,
});
console.log("run:", JSON.stringify(run, null, 2));

// The run is asynchronous even for one item; the returned sid is your handle.
// Monitor: GET /api/mass-actions/{sid}?include[]=metrics
// Control:  POST /api/mass-actions/{sid}/pause | /resume
