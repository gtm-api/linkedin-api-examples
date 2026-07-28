// Pull the contact details a profile exposes: emails, phones, websites, socials.
// Sub-record calls dispatch on a URN, so a slug-only target needs
// person-lite-profile first (see 03) or comes back not_dispatchable.
// Run: npx tsx examples/typescript/07-get-contact-info.ts ACoAA_TARGET_URN
import { gtm } from "./client.ts";

const [profileId] = process.argv.slice(2);
if (!profileId) {
  console.error("usage: 07-get-contact-info.ts <profile_id (ln_id or sn_id URN)>");
  process.exit(1);
}

const res = await gtm("/api/linkedin-enrichment/person-contact-info", {
  profile_id: profileId,
  idempotency_key: `contact-info-${profileId}`,
});
console.log(JSON.stringify(res, null, 2));
