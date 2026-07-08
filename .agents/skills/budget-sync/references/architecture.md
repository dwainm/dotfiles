# Architecture

Budget-sync is a JavaScript application that runs as a Cloudflare Worker, scheduled via cron and manually triggerable. It syncs transactions from Investec Programmable Banking accounts to a structured Google Sheets budget spreadsheet.

## Source Directory

```
src/
├── worker.js    # Cloudflare Worker entrypoint: scheduled + /run
├── sync.js      # Main sync orchestration loop
├── sheets.js    # Google Sheets API helpers
├── dates.js     # Tab name parsing, date-range math, tab category
├── investec.js  # Investec API client
└── config.js    # Local env loader (used only by Node scripts, not the worker)

scripts/
├── sync.mjs           # Manual local run via Node
├── run-deployed.mjs   # Trigger deployed worker /run endpoint
├── read-sheet.mjs     # Read-only sheet inspection (uses googleapis lib)
├── test-investec.mjs  # Test Investec API connectivity
└── setup-secrets.sh   # Push .dev.vars to wrangler secrets
```

## Worker Entrypoints

**`src/worker.js`**:
- `scheduled(event, env, ctx)` — Cron trigger (`0 4 * * *`), calls `sync(env, "cron")`.
- `fetch(request, env)` — `POST /run` with `X-Run-Key` header, calls `sync(env, "manual")`.

## Sync Flow

The `sync(env, triggerType)` function in `sync.js`:

1. **List tabs** — `listTabs(env)` returns `[{ gid, title }]` for every sheet in the spreadsheet.
2. **Color each tab** — Parse `title` as date range → categorize (`upcoming`/`current`/`past`) → `setTabColor(env, gid, rgb)`. Runs for ALL tabs, even inactive ones, so old tabs get greyed.
3. **Skip inactive tabs** — `daysSinceEnd(range) > SYNC_CUTOFF_DAYS (60)`: no more transaction syncing. If within `LOG_CUTOFF_DAYS (90)`, write a final cutoff log entry. If older than 90 days, skip entirely.
4. **For active tabs:**
   - Find sections via `getSectionRows`: scans column A for "Transactions" banner row.
   - Ensure transaction, rules, and log section headers exist.
   - Read budget (`readBudget`) — parses rows 12–99, skips rows with grey background as section headers.
   - Read rules (`readRules`) from rows 504+.
   - Fetch transactions from Investec (`fetchTransactions`) — hits each configured account's API.
   - Read existing sheet transactions, index by txId.
   - **Merge**: for each Investec transaction, if txId exists in sheet, preserve its item assignment. Otherwise set item = "".
   - **Auto-assign**: `applyRules(rules, merged)` — matches description → item via case-insensitive substring matching.
   - **Sort**: unassigned items first (for user to fill in), then by transaction date.
   - Write all rows back to the sheet (`writeAllTransactions`).
   - Set item dropdown validation and format the transaction section (`formatTransactionSection`).
   - Write SUMIFS formulas for the Actual column (`writeActualFormulas`).
   - Write "unassigned count" formula next to the Transactions banner.
   - Append a log entry.

## Scripts

### `scripts/sync.mjs` — Manual local run
Loads env from `.dev.vars` + `~/.config/budget-sync/google-sa.json`, calls `sync(env, "local")` directly. This is the primary way to test locally — no wrangler needed.

### `scripts/run-deployed.mjs` — Trigger deployed worker
POSTs to the deployed worker's `/run` endpoint using the shared key from `.run_script_key`. Requires the worker to be deployed with `RUN_SCRIPT_KEY` secret set.

### `scripts/read-sheet.mjs` — Sheet inspection
Read-only dump of a sheet tab's content using the `googleapis` npm library (not used in the worker itself). Useful for debugging layout.

### `scripts/test-investec.mjs` — API connectivity test
Tests Investec OAuth2 token exchange and lists available accounts. Used to find account IDs for `INVESTEC_ACCOUNTS`.

### `scripts/setup-secrets.sh` — Deploy secrets
Reads `.dev.vars` and pushes each key as a wrangler secret.

## No New-Month Automation

There is no code that creates new tabs or copies budget data from one month to the next. New tabs must be created manually (e.g., duplicate an existing month's sheet within the Google Sheets UI). Once created with a valid `Mmm YY` name, the sync will pick it up automatically on the next run. The "upcoming" category and yellow tab color serve as a visual indicator for tabs that exist but whose billing cycle hasn't started yet.
