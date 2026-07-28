// Run a LinkedIn people search you already built in the UI: paste its URL.
// One page per call; pass a page number to walk deeper.
// Run: npx tsx examples/typescript/06-search-people-by-url.ts "<search url>" 2
import { gtm } from "./client.ts";

const [url = "https://www.linkedin.com/search/results/people/?keywords=cto", page = "1"] =
  process.argv.slice(2);

// The URL must start with https://www.linkedin.com/search/results/people/
// Anything else is refused with 422 invalid_search_url.
const res = await gtm("/api/linkedin-scraping/search-people-by-url", {
  url,
  page: Number(page),
  idempotency_key: `search-url-p${page}`,
});
console.log(JSON.stringify(res, null, 2));
