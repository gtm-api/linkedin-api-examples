# LinkedIn API examples

Runnable examples for the [GTM API](https://gtm-api.com) LinkedIn API: search people, enrich
profiles, send connection requests and messages over plain HTTPS. Every connected LinkedIn
account runs in its own anti-detect cloud browser with a dedicated proxy; GTM API reports
20,000+ connected accounts at under a 1% ban rate.

Full reference and guides live at [docs.gtm-api.com](https://docs.gtm-api.com). For how the
official, third-party and MCP options compare, read
[LinkedIn API in 2026: The Developer Guide](https://gtm-api.com/linkedin-api/).

## Setup

1. Sign up at [app.gtm-api.com](https://app.gtm-api.com/login) (7-day trial, no card) and
   connect a LinkedIn account you own.
2. Mint an API key in the app. The secret looks like `gtm_live_` plus 40 characters and is
   shown exactly once.
3. Export it:

```bash
export GTM_API_KEY="gtm_live_YOUR_KEY"
```

The base URL is `https://app.gtm-api.com/linkedin/v4` and the key goes in the `Authorization`
header as a bearer token. Read calls work right after connect; outbound actions (invitations,
messages) become available once the account's initial sync finishes.

## First call

```bash
curl -X POST "https://app.gtm-api.com/linkedin/v4/api/linkedin-accounts/search" \
  -H "Authorization: Bearer $GTM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"page_size": 5}'
```

## Examples

| What it shows | curl | TypeScript |
|---|---|---|
| List connected LinkedIn accounts | [01-list-linkedin-accounts.sh](examples/curl/01-list-linkedin-accounts.sh) | [01-list-linkedin-accounts.ts](examples/typescript/01-list-linkedin-accounts.ts) |
| Search people by structured filters | [02-search-people.sh](examples/curl/02-search-people.sh) | [02-search-people.ts](examples/typescript/02-search-people.ts) |
| Enrich a profile from its vanity URL | [03-enrich-profile.sh](examples/curl/03-enrich-profile.sh) | [03-enrich-profile.ts](examples/typescript/03-enrich-profile.ts) |
| Send a connection request with a note | [04-send-connection-request.sh](examples/curl/04-send-connection-request.sh) | [04-send-connection-request.ts](examples/typescript/04-send-connection-request.ts) |
| Send a direct message | [05-send-message.sh](examples/curl/05-send-message.sh) | [05-send-message.ts](examples/typescript/05-send-message.ts) |
| Run a search you built in the LinkedIn UI, by URL | [06-search-people-by-url.sh](examples/curl/06-search-people-by-url.sh) | [06-search-people-by-url.ts](examples/typescript/06-search-people-by-url.ts) |
| Get emails, phones and socials off a profile | [07-get-contact-info.sh](examples/curl/07-get-contact-info.sh) | [07-get-contact-info.ts](examples/typescript/07-get-contact-info.ts) |
| List a company's employees | [08-company-employees.sh](examples/curl/08-company-employees.sh) | [08-company-employees.ts](examples/typescript/08-company-employees.ts) |
| Read the inbox and page through it | [09-read-inbox.sh](examples/curl/09-read-inbox.sh) | [09-read-inbox.ts](examples/typescript/09-read-inbox.ts) |
| Mint a cloud-browser login link for an account | [10-cloud-browser-login-link.sh](examples/curl/10-cloud-browser-login-link.sh) | [10-cloud-browser-login-link.ts](examples/typescript/10-cloud-browser-login-link.ts) |
| Bulk outreach: preview, then commit | [11-mass-action-preview-commit.sh](examples/curl/11-mass-action-preview-commit.sh) | [11-mass-action-preview-commit.ts](examples/typescript/11-mass-action-preview-commit.ts) |
| Subscribe to events and verify signatures | [12-create-webhook.sh](examples/curl/12-create-webhook.sh) | [12-create-webhook.ts](examples/typescript/12-create-webhook.ts) |

Examples 1 to 10 call the LinkedIn service at `https://app.gtm-api.com/linkedin/v4`. Mass
actions and webhooks (11 and 12) are platform-wide, so they live on the orchestration service
at `https://app.gtm-api.com/orchestration/v4`. Same key, same envelope.

The curl scripts read `GTM_API_KEY` from the environment:

```bash
./examples/curl/02-search-people.sh "growth marketing"
```

The TypeScript examples run on Node 18+ with [tsx](https://github.com/privatenumber/tsx) and
have no other dependencies:

```bash
npx tsx examples/typescript/02-search-people.ts "growth marketing"
```

## The response envelope

Every success returns the same envelope, and every error carries a machine-readable
`error.code`. The full contract, including all error codes, is documented in
[envelopes and errors](https://docs.gtm-api.com/concepts/envelopes-and-errors).

```json
{
  "success": true,
  "operation": "search",
  "items": [
    {
      "item": {
        "sid": "ln_ac_Hx7kQ3mN2pL4",
        "status": "active",
        "full_name": "Jane Cooper"
      },
      "included": {}
    }
  ],
  "counts": { "total_count": 1, "groups": { "status": { "active": 1 } } },
  "pagination": { "next_cursor": null, "has_more": false, "total_count": 1 },
  "meta": { "trace_id": "0198f2ab-7c11-7e32-9a41-d2b64f2a91c3" }
}
```

Every entity has a stable `sid` with a type prefix: `ln_ac_` for LinkedIn accounts, `ln_cv_`
for conversations, `wh_hk_` for webhooks.

## Good to know

- Outbound sends are gated server-side by per-account daily limits and a warmup curve. A
  second connection request to someone with one already pending returns a 409 instead of
  burning the account. The platform side of staying safe:
  [Safe LinkedIn Automation](https://gtm-api.com/safe-linkedin-automation/).
- Search and enrichment can run on our managed infrastructure, or through your own account
  when you pass `linkedin_account_sid`. Add an `idempotency_key` to any call to make retries
  safe.
- Bulk flows never fire from one call: preview validates the plan and mints a 15-minute
  `commit_token`, and the commit spends it. Details in
  [run a mass action](https://docs.gtm-api.com/guides/run-a-mass-action).
- Reads of already-synced data (accounts, conversations, messages) cost nothing and touch no
  LinkedIn page. Search, enrichment and sends do reach LinkedIn through the account's browser.

## Use it from an AI agent

The same API ships as an MCP server: [linkedin-mcp](https://github.com/gtm-api/linkedin-mcp).
For when MCP beats calling REST directly, read
[LinkedIn MCP Server](https://gtm-api.com/linkedin-mcp-server/).

## License

MIT
