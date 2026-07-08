# Sheet Layout

Each tab in the spreadsheet represents one billing month, named `Mmm YY` (e.g. `Jan 25`, `July 26`). The date range is **25th of prior month → 24th of named month** (parsed by `parseTabName` in `dates.js`).

## Row Map

```
Row 1–11:    Summary / Income sections (protected notes area)

Row 12–99:   Budget items
               A: Item name (budget line item)
               B: Tags
               C: Status
               D: Budget amount
               E: Actual (SUMIFS formula, auto-written)
               F: (spare)

             Grey-background rows within 12–99 are section headers
             (e.g. "Income", "Expenses", "Savings"). The sync skips
             these when building dropdowns and formulas.
             detected by isGreyBackground() in sheets.js:
             cells where R, G, B variance < 0.05 and avg < 0.95.

Row 100:     "Transactions" banner text in column A
             (found dynamically via findBannerRow; fallback = 100)

Row 101:     Transaction headers
               A: Item (dropdown from budget items)
               B: Credit
               C: Debit
               D: Date (dd/mm format)
               E: Account
               F: Description
               G: Tx ID (light grey text)

Row 102+:    Transaction data (one per row)

Row 502:     "Rules" banner text in column A

Row 503:     Rules headers: Item | Description pattern

Row 504+:    Rules data
               A: Item name (must match a budget item name after cleanName)
               B: Description pattern (case-insensitive substring match)

Row 550:     "Log" banner text in column A

Row 551:     Log headers: Date | Trigger | Details

Row 552+:    Log entries
               Date: ISO timestamp
               Trigger: "local", "manual", "cron"
               Details: summary text
```

## Sections

### Budget Section (rows 12–99)

The budget is read by `readBudget()` which returns:
- `budget[]` — array of `{ row, item, key, section, tags, status, budget, actual }`
  - `key` is the `cleanName(s)` — strips `[...]` brackets and collapses whitespace
  - `section` is inherited from the nearest grey-background row above
- `greyRows` — a `Set<rowNumber>` of section-header rows

The `cleanName()` function (`sheets.js:86`) strips text in square brackets and trims whitespace: `"Groceries [needs]"` → `"Groceries"`.

### Transactions Section (dynamic)

The banner row is found dynamically by scanning column A for the text "Transactions". This makes the section position flexible across tabs. The `getSectionRows()` function returns `{ bannerRow, headerRow, dataStartRow }`.

### Old vs New Transaction Format

The sync detects the format by checking the header row:
- **Old format**: headers at `[Item, Account, Amount, Date, Description, Tx ID]`
- **New format**: headers at `[Item, Credit, Debit, Date, Account, Description, Tx ID]`

Migration is automatic — the sync reads both formats and writes in the new format.

## Tab Colors

Set by `setTabColor()` in sheets.js via `updateSheetProperties` with `tabColorStyle.rgbColor`. Categorized by `tabCategory()` in dates.js:

| Category | Condition | Color |
|---|---|---|
| `upcoming` | today < startDate | Yellow `#FFCC00` `{ red: 1, green: 0.8, blue: 0 }` |
| `current` | startDate ≤ today ≤ endDate | Green `#00CC44` `{ red: 0, green: 0.8, blue: 0.27 }` |
| `past` | today > endDate | Grey `#B3B3B3` `{ red: 0.7, green: 0.7, blue: 0.7 }` |

Colors are refreshed every sync run (idempotent).

## Transaction Merge Logic

Transactions are matched between Investec and the sheet via `transactionId`:
```
accountId|postingDate|amount|description[:40]
```

On merge:
- If txId exists in sheet: preserve existing item assignment, update account/date/description.
- If txId is new: set item = "" (unassigned), ready for rules or manual assignment.

After merging, `applyRules()` assigns items by checking if the description contains any rule pattern (case-insensitive).

Sort order: unassigned items first (at top, ready for user), then by date ascending.
