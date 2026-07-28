// List the employees of a company, one page per call.
// Target the company by its LinkedIn URL or by its numeric id, not both.
// Run: npx tsx examples/typescript/08-company-employees.ts "https://www.linkedin.com/company/stripe/"
import { gtm } from "./client.ts";

const [companyUrl = "https://www.linkedin.com/company/stripe/", page = "1"] =
  process.argv.slice(2);

const res = await gtm("/api/linkedin-scraping/company-employees", {
  company: { company_url: companyUrl },
  page: Number(page),
  idempotency_key: `company-employees-p${page}`,
});
console.log(JSON.stringify(res, null, 2));
