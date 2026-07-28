// List the LinkedIn accounts connected to your team.
// Run: npx tsx examples/typescript/01-list-linkedin-accounts.ts
import { gtm } from "./client.ts";

const res = await gtm("/api/linkedin-accounts/search", { page_size: 10 });
console.log(JSON.stringify(res, null, 2));
