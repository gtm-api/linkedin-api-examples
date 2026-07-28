// Minimal client for the GTM API LinkedIn endpoints. No dependencies:
// Node 18+ ships fetch. Docs: https://docs.gtm-api.com
const BASE = process.env.GTM_API_BASE ?? "https://app.gtm-api.com/linkedin/v4";
const KEY = process.env.GTM_API_KEY;

export interface Envelope {
  success: boolean;
  operation: string;
  error?: { code: string; message?: string };
  [key: string]: unknown;
}

export async function gtm<T extends Envelope = Envelope>(
  path: string,
  body: Record<string, unknown> = {},
): Promise<T> {
  if (!KEY) throw new Error("export GTM_API_KEY=gtm_live_YOUR_KEY first");
  const res = await fetch(`${BASE}${path}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const json = (await res.json()) as T;
  if (!res.ok || json.success === false) {
    const code = json.error?.code ?? `http_${res.status}`;
    throw new Error(`${code}: ${json.error?.message ?? "request failed"}`);
  }
  return json;
}
