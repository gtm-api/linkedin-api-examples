// Enrich a LinkedIn profile from its vanity URL (the /in/... slug).
// Run: npx tsx examples/typescript/03-enrich-profile.ts satyanadella
import { gtm } from "./client.ts";

const [publicIdentifier = "satyanadella"] = process.argv.slice(2);

const res = await gtm("/api/linkedin-enrichment/person-lite-profile", {
  public_identifier: publicIdentifier,
  idempotency_key: `lite-profile-${publicIdentifier}`,
});
console.log(JSON.stringify(res, null, 2));
