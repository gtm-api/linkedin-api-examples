// Send a LinkedIn connection request, optionally with a note.
// The server enforces the account's daily send limit, the note length cap
// (200 chars free / 300 premium) and a 21-day resend cooldown.
// Run: npx tsx examples/typescript/04-send-connection-request.ts ln_ac_XXXX ACoAA_URN "note"
import { gtm } from "./client.ts";

const [accountSid, profileId, note] = process.argv.slice(2);
if (!accountSid || !profileId) {
  console.error("usage: 04-send-connection-request.ts <linkedin_account_sid> <profile_id> [note]");
  process.exit(1);
}

const res = await gtm("/api/linkedin-connection-requests/send", {
  linkedin_account_sid: accountSid,
  profile_id: profileId,
  note: note ?? null,
});
console.log(JSON.stringify(res, null, 2));
