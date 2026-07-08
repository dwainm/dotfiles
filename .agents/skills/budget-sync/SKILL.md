---
name: budget-sync
description: Cloudflare Worker syncing Investec bank transactions to a Google Sheets budget spreadsheet. Monthly tabs, JWT auth, transaction merging/rules, tab coloring by age, cron scheduled sync.
metadata:
  tags: cloudflare-worker, investec, google-sheets, budget, transaction-sync, javascript
---

## When to use

Use this skill when working on budget-sync:
- Modifying the sync orchestration flow (tab loop, Investec fetch, merge, write)
- Changing Google Sheets helpers (read/write/format/validate/color)
- Adjusting the Investec API integration (auth, transaction fetching)
- Modifying tab date logic, category rules, or tab coloring
- Working with the budget sheet layout (rows, sections, columns)
- Running scripts, deploying, or debugging the worker

## How to use

Reference files by topic:

- [references/architecture.md](references/architecture.md) — entrypoints, sync flow, scripts
- [references/sheet-layout.md](references/sheet-layout.md) — tab structure, row ranges, sections, budget, colors
- [references/integrations.md](references/integrations.md) — Google Sheets API + JWT auth, Investec API, env vars
- [references/how-to-update.md](references/how-to-update.md) — running, deploying, adding features, skill maintenance

Read only the file relevant to your current task.

**Agent maintenance note:** If your changes affect any area above, update the matching reference file before finishing.

---

## Quick Reference

### Key Commands

```bash
npm run sync           # Manual local run: node scripts/sync.mjs
npm run dev            # Start wrangler dev server (needs RUN_SCRIPT_KEY)
npm run deploy         # Wrangler deploy to Cloudflare
npm run run:deployed   # Trigger deployed worker's /run endpoint
npm run read           # Read a sheet tab via googleapis
npm run tail           # Follow deployed worker logs
```

### Env Vars (loaded from `.dev.vars` for local, wrangler secrets for production)

| Variable | Source | Description |
|---|---|---|
| `GOOGLE_SA_KEY` | secret | Full JSON of the Google service account |
| `SPREADSHEET_ID` | `wrangler.toml [vars]` | Google Sheet spreadsheet ID |
| `INVESTEC_CLIENT_ID` | secret | Investec OAuth2 client ID |
| `INVESTEC_CLIENT_SECRET` | secret | Investec OAuth2 client secret |
| `INVESTEC_API_KEY` | secret | Investec x-api-key |
| `INVESTEC_ACCOUNTS` | secret | CSV: `Name:AccountId,Name:AccountId` |
| `RUN_SCRIPT_KEY` | secret | Shared secret for `/run` endpoint; NOT in `.dev.vars` |

### Sheet Row Map (per tab)

| Rows | Section | Notes |
|---|---|---|
| 1–11 | Summary / Income | Protected notes area |
| 12–99 | Budget items | Grey-background rows = section headers; item, tags, status, budget, actual |
| 100 | "Transactions" banner | Found dynamically; fallback row 100 |
| 101 | Transaction header | Item, Credit, Debit, Date, Account, Description, Tx ID |
| 102+ | Transaction data | Merged from Investec + existing |
| 502 | "Rules" banner | |
| 504+ | Rules data | Item name → description pattern |
| 550 | "Log" banner | |
| 552+ | Log entries | Date, trigger type, details |

### Date Logic

- Tab names follow `Mmm YY` (e.g. `Jan 25`, `July 26`).
- Each tab is a billing month: **25th of prior month → 24th of named month**.
  - e.g. `Jan 25` covers 2024-12-25 → 2025-01-24
- `tabCategory(range)` returns `"upcoming"` (today < start), `"current"` (today in range), or `"past"` (today > end).
- Tab colors: upcoming = yellow `#FFCC00`, current = green `#00CC44`, past = grey `#B3B3B3`.

### Key Constants

```
SYNC_CUTOFF_DAYS = 60   # Stop syncing transactions after 60 days past endDate
LOG_CUTOFF_DAYS  = 90   # Stop writing log entries after 90 days past endDate
BUDGET_START_ROW = 12   # First row of budget items
BUDGET_MAX_ROW   = 99   # Last row of budget items
RULES_BANNER_ROW = 502
LOG_BANNER_ROW   = 550
```

### Project Info

```
Location: /Users/dwain/projects/budget-sync
Main:     src/worker.js (entrypoint), src/sync.js (orchestration)
Runtime:  Cloudflare Workers (compatibility_date 2024-09-23), Node for scripts
