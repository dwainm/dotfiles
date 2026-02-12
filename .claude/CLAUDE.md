# Global Claude Instructions

These instructions apply to all projects.

## Context Recovery

When context is lost due to summarization and you need to find something from earlier:

**Don't** grep/search history files directly in the main session - it's messy and wastes tokens.

**Do** spawn a sub-agent to search history:

```
Task(
  subagent_type: "Bash",
  prompt: "Reference ~/.claude/agents/history-searcher.md. Find: [WHAT YOU NEED]"
)
```

### Examples

```
# Find a task list that was discussed earlier
Task(prompt: "Reference ~/.claude/agents/history-searcher.md. Find the task list or numbered issues we were working through.")

# Find a decision or plan
Task(prompt: "Reference ~/.claude/agents/history-searcher.md. Find what we decided about [TOPIC].")

# Find a specific error or command
Task(prompt: "Reference ~/.claude/agents/history-searcher.md. Find the error message related to [FEATURE].")
```

## Task Management

**Use `j` instead of TodoWrite** for task tracking in projects. This gives you persistent, git-tracked tasks that survive sessions.

When starting multi-step work (3+ tasks), spawn the task-manager agent:

```
Task(
  subagent_type: "Bash",
  prompt: "Reference ~/.claude/agents/task-manager.md. Create tasks for: [DESCRIPTION]. Group: [session-feature-name]"
)
```

The agent will:
1. Check if `j` can be used (git repo with jobs/ dir)
2. Create grouped tasks
3. Return a task list

Then as you work:
```bash
j active "task name"   # When starting a task
j done "task name"     # When completing a task
j list --group "name"  # To show progress
```

**When to use j vs TodoWrite:**
- **j** - In git repos, for work that should persist across sessions
- **TodoWrite** - Quick scratch tasks, or when not in a git repo

## Dotfiles Management

Dotfiles are managed with a bare git repo at `~/.myconf/` with worktree at `$HOME`.

**Alias:** `config` = `git --git-dir=$HOME/.myconf/ --work-tree=$HOME`

```bash
# Check status
config status

# Add a dotfile (use -f for ignored paths)
config add -f ~/.some/dotfile

# Commit
config commit -m "Add dotfile"

# Push
config push
```

Common paths tracked:
- `~/.local/bin/` - custom scripts (j, etc.)
- `~/.claude/` - Claude agents and settings
- `~/.config/` - app configs
- `~/.zshrc`, `~/.gitconfig`, etc.

## Plan Mode Behavior

When in plan mode, **don't reprint the entire plan on every change**. Track changes mentally and only show the full plan when explicitly asked. Incremental updates should be brief summaries, not text walls.

## Global Agents

| Agent | File | Use For |
|-------|------|---------|
| **Task Manager** | `~/.claude/agents/task-manager.md` | Persistent task tracking with `j` CLI |
| **History Searcher** | `~/.claude/agents/history-searcher.md` | Find info lost to context summarization |
