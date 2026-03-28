---
name: code-review
description: Code reviewer for pattern conformance, security, testing, and Rails/Hotwire best practices
metadata:
  tags: review, code-quality, testing, security, patterns
---

## When to use

Use this skill to review code for:
- Pattern conformance (services, queries, models)
- Code style and conventions
- Security issues
- Testing coverage
- Performance concerns
- Rails 8 / Hotwire best practices

## How to use

This skill provides checklists and guidance for reviewing code.

Read the reference file for the full review checklist:
- [references/review-checklist.md](references/review-checklist.md) - Complete review checklist

---

## Quick Reference

### Commands to Run

```bash
# Ruby files - RuboCop
bin/rubocop --autocorrect

# Tests
bin/rails test
```

### Style Rules
- Double quotes only (not single)
- NO trailing whitespace
- Endless methods for one-liners
- Alphabetize associations, scopes, validations
- Private methods at bottom

### Critical Security Checks
- Strong parameters used (no `.permit!`)
- No SQL injection (parameterized queries)
- Authentication checks on sensitive actions
- Authorization scoped to `current_user`

---

## Invoke When

1. After generating new code
2. Before committing changes
3. When refactoring existing code
4. To verify spec implementation

## Output Format

Structure findings by severity:

```markdown
## Critical Issues (MUST FIX)

[Blockers that prevent merge]

## Warnings (SHOULD FIX)

[Issues that impact quality]

## Suggestions (COULD FIX)

[Nice-to-have improvements]

## Summary

[X critical, Y warnings, Z suggestions]
```
