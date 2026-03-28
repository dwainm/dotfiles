---
name: rails
description: Rails 8 expert - covers MVC, services, queries, SQLite production, Kamal deployment, and debugging patterns
metadata:
  tags: rails, ruby, sqlite, kamal, deployment, mvc, services
---

## When to use

Use this skill for Rails 8 applications:
- Rails architecture, models, controllers, and conventions
- Service objects and query patterns
- Database queries and debugging with SQLite
- Production deployment with Kamal
- Log analysis and debugging

## How to use

This skill is organized into reference files by topic:

- [references/rails-patterns.md](references/rails-patterns.md) - MVC, services, queries, jobs
- [references/rails-style.md](references/rails-style.md) - Code style and conventions
- [references/sqlite-production.md](references/sqlite-production.md) - Production SQLite config
- [references/kamal-deployment.md](references/kamal-deployment.md) - Deployment with Kamal 2
- [references/debugging.md](references/debugging.md) - Log analysis and debugging

Read only the reference file relevant to your current task.

---

## Quick Reference

### File Organization
```
app/
├── models/
│   └── concerns/           # Shared model behavior
├── controllers/
│   └── concerns/           # Authentication, Authorization
├── services/               # Domain business logic
├── queries/                # Complex database queries
├── jobs/                   # Background jobs (Solid Queue)
└── errors/                 # Custom error classes
```

### Essential Commands
```bash
bin/dev                     # Start dev server
bin/rails test             # Run tests
bin/rubocop --autocorrect   # Fix linting
bin/rails runner "..."      # Execute Rails code
```

### Code Style Rules
- Double quotes only (not single)
- NO trailing whitespace
- Endless methods for one-liners: `def name = "..."`
- Alphabetize associations, scopes, validations
- Run `bin/rubocop --autocorrect` before commits
