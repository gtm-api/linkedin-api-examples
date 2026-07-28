// Send a LinkedIn direct message to a profile URN (starts a new thread).
// To reply in an existing thread, pass linkedin_conversation_sid (ln_cv_...)
// instead of ln_id.
// Run: npx tsx examples/typescript/05-send-message.ts ln_ac_XXXX ACoAA_URN "hello"
import { gtm } from "./client.ts";

const [accountSid, lnId, text] = process.argv.slice(2);
if (!accountSid || !lnId || !text) {
  console.error("usage: 05-send-message.ts <linkedin_account_sid> <ln_id URN> <text>");
  process.exit(1);
}

const res = await gtm("/api/linkedin-messages/send", {
  linkedin_account_sid: accountSid,
  ln_id: lnId,
  text,
});
console.log(JSON.stringify(res, null, 2));
