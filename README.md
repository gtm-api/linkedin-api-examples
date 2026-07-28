# LinkedIn API examples

Runnable examples for the [GTM API](https://gtm-api.com) LinkedIn API: search people, enrich
profiles, send connection requests and messages over plain HTTPS. Every connected LinkedIn
account runs in its own anti-detect cloud browser with a dedicated proxy; GTM API reports
20,000+ connected accounts at under 1% monthly ban rate.

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
- Search and enrichment can run through the platform executor pool (charged in credits), or
  through your own account when you pass `linkedin_account_sid`. Add an `idempotency_key` to
  any paid call to make retries free.
- Bulk flows (invite 500 people from a search) are a first-class API with preview, commit
  token and canary rollout: [run a mass action](https://docs.gtm-api.com/guides/run-a-mass-action).

## Use it from an AI agent

The same API ships as an MCP server: [linkedin-mcp](https://github.com/gtm-api/linkedin-mcp).
For when MCP beats calling REST directly, read
[LinkedIn MCP Server](https://gtm-api.com/linkedin-mcp-server/).

## License

MIT
