// Read the inbox and page through it with the cursor. These are local reads
// of synced data: no LinkedIn page hit.
// Run: npx tsx examples/typescript/09-read-inbox.ts ln_ac_XXXXXXXXXXXX
import { gtm } from "./client.ts";

const [accountSid] = process.argv.slice(2);
if (!accountSid) {
  console.error("usage: 09-read-inbox.ts <linkedin_account_sid>");
  process.exit(1);
}

interface SearchEnvelope {
  success: boolean;
  operation: string;
  items: { item: Record<string, unknown>; included: Record<string, unknown> }[];
  pagination: { next_cursor: string | null; has_more: boolean };
  [key: string]: unknown;
}

let cursor: string | null = null;
let page = 0;

do {
  const res: SearchEnvelope = await gtm<SearchEnvelope>("/api/linkedin-conversations/search", {
    filter: { linkedin_account_sid: { eq: accountSid } },
    sort: { field: "last_activity_at", direction: "desc" },
    include: ["last_messages"],
    page_size: 20,
    cursor,
  });

  page += 1;
  for (const row of res.items) {
    console.log(`[page ${page}]`, JSON.stringify(row.item));
  }

  // next_cursor is opaque and forward-only; null means the last page.
  cursor = res.pagination.next_cursor;
} while (cursor && page < 3);
