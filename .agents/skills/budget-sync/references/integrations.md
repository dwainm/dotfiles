# Integrations

## Google Sheets API v4

### Authentication

The worker does NOT use the `googleapis` npm library. Instead it manually constructs and signs a JWT (RS256) to exchange for an access token.

**Flow** (`sheets.js:15-66`):
1. Read the service account JSON from `env.GOOGLE_SA_KEY`.
2. Create a JWT with `iss: client_email`, `scope: https://www.googleapis.com/auth/spreadsheets`, `aud: https://oauth2.googleapis.com/token`, `iat`/`exp`.
3. Sign with the private key via `crypto.subtle.sign("RSASSA-PKCS1-v1_5", ...)`.
4. POST to `https://oauth2.googleapis.com/token` with `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer`.
5. Cache the access token in `_tokenCache` until 60s before expiry.

### API Helper

All API calls go through `sheetsFetch(env, path, init)` (`sheets.js:68-84`):
- Accepts a path relative to `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}` (or an absolute URL for batch).
- Automatically attaches the Bearer token.
- Throws with status + first 300 chars of body on non-ok responses.

### Endpoints Used

| Method | Path | Purpose |
|---|---|---|
| GET | `?fields=sheets.properties` | List all tabs/sheets (used by `listTabs`) |
| GET | `?ranges={tab}!A{BUDGET}:F{BUDGET_MAX}&includeGridData=true` | Read budget with cell formatting (used by `readBudget`) |
| GET | `/values/{tab}!{range}` | Read values (banner, headers, transactions, rules, log) |
| PUT | `/values/{tab}!{range}?valueInputOption=USER_ENTERED` | Write values (transactions, headers, rules, log) |
| POST | `/values:batchUpdate?valueInputOption=USER_ENTERED` | Batch write actual formulas |
| POST | `:batchUpdate` | Formatting: data validation, repeatCell, hideColumn, updateSheetProperties |
| POST | `/values/{range}:clear` | Clear stale rows after writing |

### Tab Color

`setTabColor(env, sheetId, rgb)` sends a batchUpdate with:
```json
{
  "requests": [{
    "updateSheetProperties": {
      "properties": {
        "sheetId": <gid>,
        "tabColorStyle": { "rgbColor": { "red": 0, "green": 0.8, "blue": 0.27 } }
      },
      "fields": "tabColorStyle"
    }
  }]
}
```

### Caching

- `_tokenCache` — cached access token, re-fetched within 60s of expiry.
- `_sheetIdCache` — map of tab name → gid, invalidated per `sync()` call (not persisted across runs).

---

## Investec Programmable Banking API

### Authentication

OAuth2 client credentials flow (`investec.js:2-14`):
1. Basic auth with `{client_id}:{client_secret}` to `https://openapi.investec.com/identity/v2/oauth2/token`.
2. Requires `x-api-key` header in both auth and transaction requests.
3. Scope is implicit (granted by the API key).

### Transaction Fetch

`fetchTransactions({ startDate, endDate, env })` (`investec.js:51-65`):
1. Parses `env.INVESTEC_ACCOUNTS` (format: `Name:AccountId,Name:AccountId`).
2. For each account, calls `fetchRealTransactions()`.
3. GET `https://openapi.investec.com/za/pb/v1/accounts/{accountId}/transactions?fromDate={startDate}&toDate={endDate}`.

### Transaction ID

Each transaction gets a deterministic ID for merge:
```
accountId|postingDate|amount|description.slice(0, 40)
```
This allows merge to work across sync runs even if the sheet is recreated.

---

## Env Vars Reference

### How each variable reaches the code

| Variable | In Worker | In Local Run (`npm run sync`) | In `scripts/` |
|---|---|---|---|
| `GOOGLE_SA_KEY` | Wrangler secret | `~/.config/budget-sync/google-sa.json` via `config.js` | `sync.mjs` reads same file |
| `SPREADSHEET_ID` | `wrangler.toml [vars]` | Hardcoded in `config.js` | Hardcoded in each script |
| `INVESTEC_CLIENT_ID` | Wrangler secret | `.dev.vars` via `config.js` | Scripts read `.dev.vars` |
| `INVESTEC_CLIENT_SECRET` | Wrangler secret | `.dev.vars` via `config.js` | Scripts read `.dev.vars` |
| `INVESTEC_API_KEY` | Wrangler secret | `.dev.vars` via `config.js` | Scripts read `.dev.vars` |
| `INVESTEC_ACCOUNTS` | Wrangler secret | `.dev.vars` via `config.js` | Scripts read `.dev.vars` |
| `RUN_SCRIPT_KEY` | Wrangler secret | NOT in `.dev.vars` (`.run_script_key` file for `run-deployed.mjs`) | `run-deployed.mjs` reads `.run_script_key` |

The `config.js` module's `loadEnv()` function:
- Reads `.dev.vars` for INVESTEC_* vars.
- Parses `INVESTEC_ACCOUNTS` into `INVESTEC_ACCOUNT_LIST` array `[{ name, id }]`.
- Reads `~/.config/budget-sync/google-sa.json` for the service account key.
- NOTE: `config.js` is **only loaded by Node scripts**, not by the Cloudflare Worker. In the worker, all env vars come via the `env` parameter passed to `scheduled()`/`fetch()` handlers.
