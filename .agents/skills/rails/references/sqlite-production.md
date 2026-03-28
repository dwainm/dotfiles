# SQLite Production Configuration

## Overview

SQLite in production requires careful configuration for WAL mode, concurrency handling, and backups.

## Essential database.yml Settings

```yaml
# config/database.yml
production:
  adapter: sqlite3
  database: storage/production.sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
```

## Recommended Initializer

```ruby
# config/initializers/sqlite3.rb
if ActiveRecord::Base.connection.adapter_name == "SQLite"
  ActiveRecord::Base.connection.execute <<-SQL
    PRAGMA journal_mode = WAL;
    PRAGMA synchronous = NORMAL;
    PRAGMA busy_timeout = 5000;
    PRAGMA cache_size = -64000;
    PRAGMA foreign_keys = ON;
    PRAGMA temp_store = MEMORY;
    PRAGMA mmap_size = 134217728;
  SQL
end
```

## Key PRAGMAs Explained

| PRAGMA | Value | Purpose |
|--------|-------|---------|
| `journal_mode = WAL` | Required | Write-Ahead Logging for concurrent reads |
| `synchronous = NORMAL` | Required | Balance durability and performance |
| `busy_timeout = 5000` | 5000ms | Wait for locks instead of immediate error |
| `cache_size = -64000` | 64MB | Page cache for better performance |
| `foreign_keys = ON` | ON | Enforce referential integrity |

## WAL Mode

**Why WAL?** Write-Ahead Logging allows concurrent readers while one writer is active.

```ruby
# Enable WAL mode (do this once, it persists)
ActiveRecord::Base.connection.execute("PRAGMA journal_mode = WAL;")

# Verify WAL is active
result = ActiveRecord::Base.connection.execute("PRAGMA journal_mode;")
puts result.first["journal_mode"] # Should output: "wal"
```

## Migration Strategies

SQLite has limited ALTER TABLE support. Plan migrations carefully.

### Supported Operations
```ruby
add_column :budgets, :description, :string
add_index :bank_transactions, :date
remove_column :budgets, :legacy_field
```

### Operations Requiring Table Rebuild
```ruby
# Type changes require table rebuild
change_column :budgets, :name, :text  # NOT directly supported

# Workaround: Create new table, copy data, rename
```

## Query Performance

### Always Use EXPLAIN
```ruby
# Check query plan
result = ActiveRecord::Base.connection.execute(
  "EXPLAIN QUERY PLAN #{sql}"
)
result.each { |row| puts row }
```

### Indexing
```ruby
# Add indexes on frequently queried columns
add_index :bank_transactions, :date
add_index :bank_transactions, [:budget_id, :date]
add_index :bank_transactions, :description  # For search

# Partial indexes for common queries
add_index :bank_transactions, :category_id,
  where: "category_id IS NULL",
  name: "index_uncategorized_transactions"
```

## Concurrency Handling

SQLite has a single writer limitation. BUSY_TIMEOUT is essential:

```ruby
PRAGMA busy_timeout = 5000;  # Wait up to 5 seconds for locks
```

## Backups with Litestream

Litestream provides continuous replication for SQLite.

### Installation
```bash
# On server
wget https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz
tar -xzf litestream-v0.3.13-linux-amd64.tar.gz
sudo mv litestream /usr/local/bin/
```

### Configuration (litestream.yml)
```yaml
# /etc/litestream.yml
dbs:
  - path: /app/storage/production.sqlite3
    replicas:
      - url: s3://mybucket/klop/db
        region: us-east-1
        access-key-id: $AWS_ACCESS_KEY_ID
        secret-access-key: $AWS_SECRET_ACCESS_KEY
```

### Kamal Hooks
```yaml
# config/deploy.yml
hooks:
  pre-deploy:
    - command: "docker exec $(docker ps -q -f name=klop) litebackup"
  post-deploy:
    - command: "docker exec $(docker ps -q -f name=klop) litestream replicate"
```

## When SQLite IS a Good Fit

- Single-server deployments
- Read-heavy workloads
- Data < 1TB
- Budgeting apps with moderate concurrency

## When SQLite IS NOT a Good Fit

- High write concurrency (many simultaneous writers)
- Multi-server setups requiring shared database
- Complex reporting with heavy analytical queries
- Data > 1TB

## SQLite + Rails 8 Benefits

- Solid Queue: SQLite-backed background jobs
- Solid Cache: SQLite-backed fragment caching
- Solid Cable: SQLite-backed Action Cable

All work seamlessly with SQLite in production.

## Monitoring

Check for common issues:

```ruby
# Check database size
bin/rails runner "
  size = File.size('storage/production.sqlite3')
  puts \"Database size: #{size / 1.megabyte} MB\"
"

# Check WAL file size
bin/rails runner "
  wal_size = File.size('storage/production.sqlite3-wal') rescue 0
  puts \"WAL size: #{wal_size / 1.megabyte} MB\"
"

# Checkpoint if WAL is too large
bin/rails runner "
  ActiveRecord::Base.connection.execute('PRAGMA wal_checkpoint(TRUNCATE);')
"
```
