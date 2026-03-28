# Code Review Checklist

Complete checklist for reviewing Rails/Hotwire code.

## 1. Pattern Conformance

### Service Objects
- [ ] Inherits from `ApplicationService`
- [ ] Uses `Result` pattern for return values
- [ ] Has `def self.call(...)` shortcut
- [ ] Dependencies passed to `initialize`
- [ ] Business logic extracted from controller
- [ ] Private methods at bottom with `private` keyword

### Query Objects
- [ ] Inherits from `ApplicationQuery`
- [ ] Has `def self.call(...)` shortcut
- [ ] Accepts `relation` parameter for chaining
- [ ] Returns `ActiveRecord::Relation`
- [ ] Methods are chainable

### Controllers
- [ ] Thin controllers (logic in services)
- [ ] Uses `before_action` for common setup
- [ ] Strong parameters defined
- [ ] Proper status codes (`:unprocessable_entity` for errors)
- [ ] Authorization scoping to `current_user`

### Models
- [ ] Structure: associations → validations → scopes → callbacks → methods
- [ ] Associations alphabetized
- [ ] Validations alphabetized
- [ ] Scopes alphabetized
- [ ] Uses `default_scope` appropriately
- [ ] Service objects preferred over callbacks

### Background Jobs
- [ ] In `app/jobs/`
- [ ] Uses Solid Queue
- [ ] Accepts primitive arguments (not AR objects)
- [ ] Handles failures gracefully
- [ ] Idempotent (safe to run multiple times)

## 2. Code Style

### Ruby Style
- [ ] Double quotes (not single)
- [ ] No trailing whitespace
- [ ] Endless methods for one-liners: `def name = "..."`
- [ ] Methods under 20 lines
- [ ] Class under 100 lines (ideally)

### Naming
- [ ] Class names are nouns (`UserCreator`, not `CreateUser`)
- [ ] Method names are verbs (`create_user`, not `user_creator`)
- [ ] Boolean methods end with `?` (`active?`)
- [ ] Constants are SCREAMING_SNAKE_CASE

### Organization
- [ ] Private methods at bottom
- [ ] Related methods grouped
- [ ] Single responsibility per class
- [ ] One idea per method

## 3. Security

### Input Handling
- [ ] Strong parameters used
- [ ] No `.permit!`
- [ ] Input sanitization for display
- [ ] File upload validation (type, size)

### Database
- [ ] No SQL injection (parameterized queries)
- [ ] No mass assignment vulnerabilities
- [ ] Transaction used for multi-step operations

### Authentication/Authorization
- [ ] Authentication check on sensitive actions
- [ ] Authorization scoping to `current_user`
- [ ] No ID parameter tampering (use scoped finds)
- [ ] CSRF protection enabled

### Secrets
- [ ] No hardcoded secrets
- [ ] No secrets in version control
- [ ] ENV or Rails credentials used

## 4. Testing

### Coverage
- [ ] Tests exist for new code
- [ ] Happy path tested
- [ ] Error cases tested
- [ ] Edge cases considered

### Test Quality
- [ ] Tests are isolated (no order dependencies)
- [ ] No external service calls in tests (mock/stub)
- [ ] FactoryBot fixtures used
- [ ] Descriptive test names

### Test Types
- [ ] Unit tests for models
- [ ] Request/controller tests
- [ ] Service tests
- [ ] System/feature tests for critical paths

## 5. Performance

### Database
- [ ] No N+1 queries (use `includes`, `preload`)
- [ ] Pagination on list views
- [ ] Indexes on queried columns
- [ ] `select` used to limit columns when needed

### Caching
- [ ] Fragment caching for expensive renders
- [ ] Russian doll caching for nested content
- [ ] Cache keys properly versioned

### Background Processing
- [ ] Slow operations in jobs
- [ ] Mailers sent asynchronously
- [ ] File processing in jobs

## 6. Rails 8 / Hotwire

### Turbo
- [ ] Turbo Frame IDs match between request/response
- [ ] `respond_to` with `format.turbo_stream`
- [ ] Proper status codes in stream responses
- [ ] No inline JavaScript

### Stimulus
- [ ] Controllers use targets (not querySelector)
- [ ] Values used for configuration
- [ ] Actions on appropriate elements
- [ ] Cleanup in `disconnect()`

### Hotwire Integration
- [ ] Frames have proper IDs
- [ ] Stream responses for async updates
- [ ] Stimulus controllers for complex interactions
- [ ] No JavaScript in ERB (use data attributes)

## 7. Documentation

### Code Comments
- [ ] Complex logic explained
- [ ] Public API documented
- [ ] "Why" not "What" comments
- [ ] No commented-out code

### Commit Messages
- [ ] Clear, descriptive message
- [ ] Explains "why" not just "what"
- [ ] References issue if applicable

## 8. Error Handling

### Graceful Degradation
- [ ] Failures handled gracefully
- [ ] User-friendly error messages
- [ ] Errors logged appropriately
- [ ] Rollback on transaction failure

### Custom Errors
- [ ] Domain-specific error classes
- [ ] Errors in `app/errors/`
- [ ] Proper error hierarchy

## Response Format

```markdown
## Critical Issues (MUST FIX)

### File: app/services/budget_service.rb
- **Issue**: SQL injection vulnerability in `search` method
- **Fix**: Use parameterized query: `where("name LIKE ?", "%#{term}%")`

## Warnings (SHOULD FIX)

### File: app/controllers/budgets_controller.rb
- **Issue**: No pagination on `index` action
- **Fix**: Add `pagy` or `kaminari` pagination

## Suggestions (COULD FIX)

### File: app/models/budget.rb
- **Suggestion**: Extract validation logic to custom validator class

## Summary

- **Critical**: 1 (blocks merge)
- **Warnings**: 1 (should address)
- **Suggestions**: 1 (nice to have)

## Next Steps

1. Fix critical SQL injection issue
2. Add pagination to index action
3. Consider custom validator (optional)
```

## Commands to Run

```bash
# Check style
bin/rubocop --autocorrect

# Run tests
bin/rails test

# Check security
bundle exec brakeman -A

# Check dependencies
bundle audit
```
