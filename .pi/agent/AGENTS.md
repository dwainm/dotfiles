# Pi Harness Configuration

This directory contains my pi coding agent harness configuration at `~/.pi`.

## Principles

- **Version controlled via yadm**: All config files tracked in dotfiles repo at `~/.local/share/yadm/repo.git`
- **Secrets excluded**: `auth.json`, sessions/ never committed
- **Config as code**: Changes via settings.json

## Naming Convention

- `AGENTS.md` — Context for agent (this file)
- `SKILL.md` — Skill definitions

## Version Control

Yadm stores its git data at `~/.local/share/yadm/repo.git` (XDG_DATA_HOME location).

```bash
yadm status         # Check changes
yadm add <file>     # Stage files
yadm commit -m "..."# Commit
yadm push           # Push to remote
```

---

# Agent Workflow

## Active Extensions

### 1. Purpose Gate
Captures session intent. Purpose appears in banner. Stay focused on it.

**Commands:** `/purpose`

### 2. Task Tracking (`/task`)
Lightweight task organization. Use tasks to break up work and track progress. **Non-blocking** — you can use tools without tasks defined.

**Workflow:**
```
task list              # See current tasks
task new-list "Name"   # Start fresh list (with optional description)
task add "Do thing"    # Add task(s)
task add "Task A" "Task B"  # Add multiple
task toggle 1          # idle → inprogress → done
task remove 3          # Delete a task
task clear             # Wipe all (with confirm)
/task                  # Interactive overlay
```

**Using Tasks to Break Up Work:**
- At session start: `task list` → add tasks for what you plan to do
- Before complex work: Break into small, actionable tasks
- During work: Toggle tasks as you complete them
- Update this file: Add completed work to the "Recent Work Log" below

**Updating AGENTS.md as you go:**
Keep this file current by adding completed tasks to the log. This maintains context across sessions.

**Commands:** `list`, `new-list`, `add`, `toggle N`, `remove N`, `clear`, `/task`

### 3. Damage Control
Blocks dangerous commands (`rm -rf /`, `~/.pi` modifications). Automatic.

### 4. Tool Counter
Shows model, context, tokens, cost in footer. Monitor for >80% context.

### 5. Tmux Session Status
Updates tmux window title. Automatic.

### 6. Harness Review
Analyzes sessions. `/review-all-sessions`, `/review-session`

### 7. Exit Alias
`/exit` = `/quit`

---

## Workflow

**Session Start:**
1. Acknowledge purpose
2. `task list` → check existing tasks
3. Add tasks for planned work
4. `task toggle` to mark active work

**During Work:**
- Stay on purpose
- Add tasks as needed, toggle each
- Update AGENTS.md "Recent Work Log" as you complete things
- Suggest git commits

**Session End:**
- Check incomplete tasks
- Update Recent Work Log below
- `yadm add/commit` if harness modified

---

## Recent Work Log

<!-- Add completed work here as you go -->
<!-- Format: - YYYY-MM-DD: Brief description of what was done -->

- 2025-03-25: Fixed tool-counter extension - non-blocking pricing fetch with disk cache; removed broken theme application (THEME_MAP referenced non-existent themes)
- 2025-03-19: Renamed tilldone extension to task, removed blocking behavior, updated AGENTS.md docs

---

## Workflow Principles

### File Editing Discipline
**ALWAYS read before editing.** Use the `read` tool immediately before any `edit` operation:
- Prevents unintentional deletions of content added between operations
- Catches context changes that affect the edit
- Ensures oldText matches exactly what's currently in the file

**Never assume file state** — even if you just edited it, re-read if:
- User may have modified it in another editor
- Time has passed between operations  
- You're about to delete or replace significant content

**Before structural changes** (moving paragraphs, combining sentences, deleting content):
1. Read the file
2. Quote the exact before/after to the user
3. Get explicit confirmation before proceeding

### Verification After Editing
**ALWAYS verify after editing.** Don't assume the code works — prove it:

1. **Re-read the file** after the edit to confirm the change landed correctly
2. **Run the code** to verify actual behavior:
   - For logic changes: `bin/rails runner 'puts ClassName.new.method'`
   - For tests: `bin/rails test test/path/to_test.rb`
   - For scripts: Execute them directly
3. **Check configuration exists** before referencing it:
   - Before using `Rails.application.credentials.dig(:key)`, verify it exists
   - If referencing env vars, check they're set: `echo $VAR_NAME`
4. **If user corrects you** — immediately re-read the file to see current state

**The "Three-Prompt Rule":** If you make an error and the user points it out, do NOT:
- Argue about what "should" work
- Explain why your logic was correct
- Move on without verifying

DO:
- Re-read the affected file immediately
- Run the actual code to see what happens
- Acknowledge the specific error, not a generalized "I made a mistake"

### Configuration Safety
When working with Rails credentials, environment variables, or any configuration:

1. **Check before using**: `bin/rails runner 'puts Rails.application.credentials.dig(:namespace, :key).inspect'`
2. **Handle nil explicitly**: Use `== true` or `== "value"` instead of truthy checks
3. **Default defensively**: `config_value || fallback` can hide missing config; prefer explicit checks

**Example — Bad:**
```ruby
@sandbox = Rails.application.credentials.dig(:payfast, :sandbox) || Rails.env.development?
```
If the credential doesn't exist, this silently falls back. But if the credential IS set to `false` in production, it would incorrectly use development logic.

**Example — Good:**
```ruby
@sandbox = Rails.env.development? || Rails.application.credentials.dig(:payfast, :sandbox) == true
```
Development always forces sandbox. Production only uses sandbox if explicitly set to `true`.

### When the User Catches an Error
If the user points out an error, especially one that persisted across multiple prompts:

1. **Stop explaining** — Don't say "I meant to..." or "The logic should..."
2. **Re-read immediately** — Use `read` on the affected file right now
3. **Show the current state** — Quote what the file actually says
4. **Run the actual code** — `bin/rails runner` or test file to prove behavior
5. **Name the specific error** — Not "I made a mistake" but "I wrote X when it should have been Y because Z"

**Do NOT:**
- Recommend other models (deflecting)
- Give generic "I'll do better" (empty promise)
- Move on without proving the fix
- Argue about what "should" happen

**The user is debugging your behavior, not just the code.** Treat their feedback as a bug report about YOU.

### Model Limitations — Know Thyself
The model does NOT have:
- Memory of files between reads (only conversation history)
- Knowledge of what "should" be in a file
- Awareness of missing configuration
- Certainty about code behavior without running it

**Trust = Verification.** The model claiming "this works" means nothing without proof.

### Task = Organization, Not Enforcement
- **Optional** — Use tools without tasks if you want
- **Break up work** — Complex requests → multiple small tasks
- **Track progress** — Toggle tasks as you go
- **Update this file** — Keep the Recent Work Log current

### Git Workflow (via yadm)
All harness changes are tracked in yadm's dotfiles repo:
```
yadm status       # See what's changed
yadm add <file>   # Stage files
yadm commit -m "..."
yadm push         # Push to dotfiles repo
```

Yadm git data lives at `~/.local/share/yadm/repo.git`.

### Session Lifecycle
1. **Start** → Acknowledge purpose → `task list` → add tasks → toggle → work
2. **Work** → Stay on purpose → toggle tasks → update Recent Work Log → suggest git commits
3. **End** → Update log → `config add/commit` if harness modified
