# How to Update

## Running Locally

### Direct Node Run (recommended for development)
```bash
npm run sync
```
Loads env from `.dev.vars` and `~/.config/budget-sync/google-sa.json`, calls `sync()` directly. No wrangler needed. This is the fastest feedback loop.

### Wrangler Dev Server
```bash
npm run dev
```
Starts a local HTTP server. Requires `RUN_SCRIPT_KEY` in `.dev.vars` (or you'll get 401 when POSTing). Then:
```bash
curl -X POST http://localhost:8787/run -H "X-Run-Key: your-key"
```

### Trigger Deployed Worker
```bash
npm run run:deployed
```
POSTs to the production worker URL using the key from `.run_script_key`. Good for checking production behavior.

## Deploying

```bash
npm run deploy         # wrangler deploy
bash scripts/setup-secrets.sh   # push latest secrets from .dev.vars
```

The worker cron is set to `0 4 * * *` (daily at 4am).

## Adding a Feature

### Common patterns:

1. **New sheet section** — add string constants (banner row numbers) in `sync.js`, add `ensure*Section()` helper in `sheets.js`, call it in the sync loop.
2. **New transaction format** — the existing old/new detection in `readAllTransactions` is the pattern: check header row, map columns conditionally.
3. **New env var** — add to `.dev.vars`, `wrangler.toml` (if non-secret), `scripts/setup-secrets.sh` (if secret), `config.js` (for local runs).
4. **New tab behavior** — the tab loop in `sync.js` runs all tabs. Add hooks before or after the `isTabActive` check depending on whether inactive tabs should be included.

### Testing Changes

1. Run `npm run sync` to test locally against the real Google Sheet and Investec API.
2. Check the console output for each tab's `=== Tab Name ===` section.
3. Verify the sheet in Google Sheets after the run.
4. Deploy with `npm run deploy` when ready.

## Known Gaps

- **No automated new-month tab creation.** Tabs must be created manually (duplicate an existing month in the Google Sheets UI). Once created with a valid `Mmm YY` name, the next sync picks it up.
- **Tab color is set every sync** (not just on change). This is intentional for simplicity — one extra API call per tab per run.
- **Transaction merge is append-only.** Existing rows are never deleted; stale rows beyond the data range are cleared via the `:clear` POST in `writeAllTransactions`.

## Skill Maintenance

If you modify the code in a way that changes the architecture, sheet layout, or integrations:

1. Update the relevant reference file(s) in `~/.agents/skills/budget-sync/references/`.
2. If the Quick Reference section in `SKILL.md` is affected, update that too.
3. Track via yadm:
```bash
yadm add -f ~/.agents/skills/budget-sync/
yadm commit -m "update budget-sync skill: <what changed>"
yadm push
```
