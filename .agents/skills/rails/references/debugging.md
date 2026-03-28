# Debugging and Log Analysis

## Log Awareness

When debugging Rails issues, use the log system intelligently to avoid bloating session context.

### Rules

1. **Never read logs directly** (unless user explicitly asks)
   - ❌ `tail -200 log/development.log | grep error`
   - ❌ Reading entire log files
   - ✅ Use `bin/log-compressor` via sub-agent

2. **When to check logs:**
   - After user reports unexpected behavior
   - After test failures involving server requests
   - When investigating controller/model/Stimulus issues
   - Every 2-3 interactions during active debugging

3. **How to check logs:**
   ```bash
   bin/log-compressor --context "CONTEXT" --watch "KEYWORDS"
   ```

### Examples

```bash
# Debugging schedule panel
bin/log-compressor --context "schedule panel Stimulus controller" --watch "schedule,stimulus,toggle"

# Investigating budget deletion
bin/log-compressor --context "budget deletion flow" --watch "budget,destroy,delete"

# General check
bin/log-compressor
```

## Log Compressor Output Format

```
---
ERRORS: 0 | or count + details
REQUESTS: METHOD /path status count
SLOW: slow queries or requests
RELEVANT: matches to context/watch keywords
N_PLUS_ONE: detected patterns
ACTION_NEEDED: no | yes: reason
TIMESTAMP: when analyzed
---
```

## Responding to Log Output

**If summary shows no issues (ACTION_NEEDED: no):**
```
Logs clean. 12 requests (all 200), no errors, no matches for "schedule".
```

**If summary shows issues (ACTION_NEEDED: yes):**
```
ERRORS: 2 - ActionView::Template::Error in schedule_panel at line 45
RELEVANT: Found "schedule_panel_controller" error at 04:12:33
Interpretation: Template error in the exact file you're debugging - check line 45.
```

## Rails Runner for Debugging

### Template
```ruby
bin/rails runner "
  result = MODEL.unscoped.where(CONDITIONS).limit(10)
  if result.any?
    result.each { |r| puts r.attributes.slice('id', 'KEY_FIELDS').to_json }
  else
    puts 'NOT_FOUND'
  end
"
```

### Examples

```ruby
# Find a budget
bin/rails runner "
  b = Budget.unscoped.find_by(id: 123)
  puts b ? b.attributes.slice('id', 'number', 'year', 'title').to_json : 'NOT_FOUND'
"

# Count line items
bin/rails runner "
  count = LineItem.unscoped.where(budget_id: 123).count
  puts({ budget_id: 123, line_item_count: count }.to_json)
"

# Check schedule sources
bin/rails runner "
  LineItem.unscoped.where(budget_id: 123).where.not(schedule_source_id: nil).each do |li|
    puts({ id: li.id, name: li.name, schedule_source_id: li.schedule_source_id }.to_json)
  end
"
```

## Debug Mode (Stimulus)

```javascript
// app/javascript/application.js
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = true  // Logs Stimulus lifecycle events

window.Stimulus = application
```

## Common Debugging Scenarios

### Model Scoping Issues
```ruby
# Always use .unscoped in runner
bin/rails runner "Budget.unscoped.find(123)"  # ✅
bin/rails runner "Budget.find(123)"            # ❌ May fail due to default_scope
```

### Check Database State
```ruby
# Verify associations
bin/rails runner "
  b = Budget.unscoped.find(123)
  puts({ 
    id: b.id, 
    user_id: b.user_id,
    months_count: b.months.count,
    line_items_count: LineItem.unscoped.where(budget_id: b.id).count 
  }.to_json)
"
```

### Verify Migrations
```ruby
# Check if column exists
bin/rails runner "
  puts ActiveRecord::Base.connection.column_exists?('budgets', 'new_column')
"

# List tables
bin/rails runner "
  puts ActiveRecord::Base.connection.tables
"
```

## N+1 Query Detection

Watch for in logs:
```
N_PLUS_ONE: Budget Load (1.2ms) repeated 15 times
```

Fix with `includes`:
```ruby
# Bad - N+1
@budgets = Budget.all
@budgets.each { |b| b.months.count }

# Good - eager load
@budgets = Budget.includes(:months).all
@budgets.each { |b| b.months.count }
```
