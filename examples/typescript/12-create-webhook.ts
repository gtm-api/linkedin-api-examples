// Subscribe to events instead of polling: new replies, accepted invitations,
// account login trouble. Webhooks live on the orchestration service.
// The 32-char secret comes back ONCE here and is masked on every later read,
// so store it now: it is what verifies delivery signatures.
// Run: npx tsx examples/typescript/12-create-webhook.ts https://example.com/hooks/gtm
import crypto from "node:crypto";
import { gtmOrchestration } from "./client.ts";

const [targetUrl] = process.argv.slice(2);
if (!targetUrl) {
  console.error("usage: 12-create-webhook.ts <https target_url>");
  process.exit(1);
}

// target_url must be https and resolve to a public address.
const res = await gtmOrchestration("/api/webhooks", {
  name: "Inbox and invitations",
  target_url: targetUrl,
  events: [
    "linkedin-messages.received",
    "linkedin-connection-requests.accepted",
    "linkedin-accounts.login-failed",
  ],
  // Narrow to a single account with:
  // filters: { account_sid: "ln_ac_XXXXXXXXXXXX" },
});
console.log(JSON.stringify(res, null, 2));

// Send yourself a sample delivery: POST /api/webhooks/{sid}/test

/**
 * Verify an incoming delivery. Every request carries
 * X-Webhook-Signature: t={unix_seconds},v1={hex_hmac}, where the HMAC is
 * SHA-256 over "{t}.{raw_body}" keyed with the secret above.
 *
 * Hash the RAW bytes you received, before any JSON re-serialization: parsing
 * and re-encoding can reorder keys and break the signature.
 */
export function verifyWebhookSignature(
  rawBody: string,
  signatureHeader: string,
  secret: string,
): boolean {
  const parts = Object.fromEntries(
    signatureHeader.split(",").map((p) => p.split("=") as [string, string]),
  );
  // Reject anything older than 5 minutes: the timestamp blocks replays.
  if (Math.abs(Date.now() / 1000 - Number(parts.t)) > 300) return false;

  const expected = crypto
    .createHmac("sha256", secret)
    .update(`${parts.t}.${rawBody}`)
    .digest("hex");
  const received = parts.v1 ?? "";
  if (expected.length !== received.length) return false;
  return crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(received));
}
