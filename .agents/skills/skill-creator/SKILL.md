---
name: skill-creator
description: Guide for creating, updating, and improving opencode skills - conventions, structure, discovery, and best practices for SKILL.md authoring
metadata:
  tags: skill-creation, authoring, templates, conventions
---

## When to use

Use this skill when:
- Creating a new skill for opencode — **always search first** to avoid duplicates
- Updating or improving an existing skill's structure
- Converting an agent or knowledge into a reusable skill
- Checking if a skill follows conventions

**Before creating ANY new skill**, follow the discovery workflow below. A community skill likely already exists.

## How to use

Always search first — a community skill may already exist. Then scaffold with the CLI, then customize.

- [references/skill-template.md](references/skill-template.md) - Complete template with all sections
- [references/conventions.md](references/conventions.md) - Naming, structure, best-practice rules
- [references/discovery.md](references/discovery.md) - Finding skills before creating new ones

Read only the reference file relevant to your current task.

---

## Quick Reference

### Discovery: Find Before You Build
```bash
npx skills find <query>         # Interactive search on skills.sh
npx skills list -g              # List already-installed global skills
```

Top skill repositories to check:
| Repository | Focus |
|---|---|
| `vercel-labs/agent-skills` | React, Next.js, design, deployment |
| `anthropics/skills` | Frontend design, MCP, PDF/pptx/docx |
| `microsoft/azure-skills` | Azure cloud services |
| `supabase/agent-skills` | Supabase, Postgres |
| `remotion-dev/skills` | Remotion video |
| `obra/superpowers` | Dev workflow, TDD, code review |
| `mattpocock/skills` | TypeScript, TDD |
| `pbakaus/impeccable` | UI polish, design critique |

### Scaffolding
```bash
npx skills init <name>          # Creates SKILL.md skeleton
npx skills add <owner/repo>     # Install community skills
```

### Directory Structure
```
~/.agents/skills/<name>/
  SKILL.md               # Required: main definition (ALL CAPS filename)
  references/             # Optional: supplementary docs
    topic-a.md
    topic-b.md
  rules/                  # Optional: alternative to references/
    rule-a.md
  assets/                 # Optional: code samples, templates
```

### Required Frontmatter
| Field | Constraints |
|-------|-------------|
| `name` | 1-64 chars, lowercase alphanumeric + single hyphens, must match directory name |
| `description` | 1-1024 chars, determines when the agent loads the skill |

### Body Sections (Convention)
1. `## When to use` — triggers/conditions for loading
2. `## How to use` — links to reference files
3. `---` (separator)
4. `## Quick Reference` — key info the agent can use immediately

### Key Rules
- Filename MUST be `SKILL.md` (uppercase)
- Keep SKILL.md under ~80 lines; put details in references/
- Description is critical — the agent scans it to decide when to load
- No blank spaces in directory name; use hyphens only
- Names must be unique across all skill locations

### After Creating or Editing a Skill

Skills live in `~/.agents/skills/` which is tracked by yadm (dotfiles manager).
After creating or modifying any skill file:

```bash
yadm add -f ~/.agents/skills/<name>/SKILL.md
yadm commit -m "add/update <name> skill"
yadm push
```

Note: `-f` is required because `.agents/` is in the global gitignore.
