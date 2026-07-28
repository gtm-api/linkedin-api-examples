// Search LinkedIn people with structured filters (no search URL needed).
// Run: npx tsx examples/typescript/02-search-people.ts "growth marketing" "CEO"
import { gtm } from "./client.ts";

const [keywords = "growth marketing", title] = process.argv.slice(2);

const res = await gtm("/api/linkedin-scraping/search-people-by-params", {
  filters: { keywords, title: title ?? null },
  // Reuse the same key when retrying: the ledger returns the stored outcome
  // instead of executing (and charging) again.
  idempotency_key: `search-people-${Date.now()}`,
});
console.log(JSON.stringify(res, null, 2));
