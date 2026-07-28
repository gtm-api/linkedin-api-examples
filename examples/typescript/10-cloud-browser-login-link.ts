// Hand someone a link to sign a LinkedIn account into its cloud browser.
// Every connected account runs in its own anti-detect browser behind a
// dedicated proxy; this mints a scoped, expiring link to that browser so the
// account owner can log in without a platform account of their own.
//
// The response carries access_key (shown once) and public_connect_url. That
// URL is a bearer secret granting remote browser access: keep the TTL short,
// cap the connects, and send it over a private channel.
// Run: npx tsx examples/typescript/10-cloud-browser-login-link.ts [ab_br_XXXXXXXXXXXX]
import { gtm, type Envelope } from "./client.ts";

interface SearchEnvelope extends Envelope {
  items: { item: { sid: string; [key: string]: unknown } }[];
}

let [browserSid] = process.argv.slice(2);

if (!browserSid) {
  const browsers = await gtm<SearchEnvelope>("/api/antidetect-browsers/search", { page_size: 1 });
  browserSid = browsers.items[0]?.item.sid ?? "";
  if (!browserSid) {
    console.error("no anti-detect browser on this team yet, connect an account first");
    process.exit(1);
  }
  console.error(`no sid given, using ${browserSid}`);
}

const res = await gtm("/api/antidetect-browsers/generate-cloud-browser-access-key", {
  sid: browserSid,
  ttl_hours: 4,
  max_connects: 3,
  // Optional scoping, checked at connect time:
  // allowed_ips: ["203.0.113.10"],
  // allowed_countries: ["DE"],
});
console.log(JSON.stringify(res, null, 2));

// Revoke early with POST /api/antidetect-browsers/revoke-cloud-browser-access-key
