---
name: hotwire
description: Hotwire expert for Rails 8 - Turbo Drive/Frames/Streams, Stimulus controllers, real-time updates, and advanced patterns from Hotwire Club
metadata:
  tags: hotwire, turbo, stimulus, rails, realtime, frames, streams
---

## When to use

Use this skill for:
- Turbo Drive navigation and form handling
- Turbo Frames for partial page updates
- Turbo Streams for real-time updates
- Stimulus controllers and JavaScript integration
- Advanced patterns: loading states, inline editing, typeahead, optimistic UI

## How to use

This skill is organized into reference files by topic:

- [references/turbo-drive.md](references/turbo-drive.md) - Navigation, forms, activity indicators
- [references/turbo-frames.md](references/turbo-frames.md) - Lazy loading, inline editing, modals
- [references/turbo-streams.md](references/turbo-streams.md) - Real-time updates, custom actions
- [references/stimulus-basics.md](references/stimulus-basics.md) - Controllers, targets, values
- [references/stimulus-advanced.md](references/stimulus-advanced.md) - Outlets, patterns
- [references/ux-patterns.md](references/ux-patterns.md) - Loading spinners, optimistic UI
- [references/integration.md](references/integration.md) - Combining technologies

Read only the reference file relevant to your current task.

---

## Quick Reference

### Key Technologies

| Need | Solution |
|------|----------|
| Fast page navigation | Turbo Drive (automatic) |
| Update part of page | Turbo Frames |
| Real-time updates | Turbo Streams + Action Cable |
| Complex UI interactions | Stimulus controllers |
| Loading states | UX patterns + `busy` attribute |
| Form validation | Turbo Frames + Stimulus |
| Modals, dropdowns | Stimulus + Turbo Frames |

### Common Events

| Event | When it fires |
|-------|---------------|
| `turbo:load` | After page load (like DOMContentLoaded) |
| `turbo:submit-start` | Before form submission |
| `turbo:submit-end` | After form submission completes |
| `turbo:frame-render` | After a Turbo Frame renders |
| `turbo:before-frame-render` | Before a Turbo Frame renders (can pause) |

### Stimulus Lifecycle

```javascript
connect()      // Element inserted into DOM
initialize()   // Controller instance created
disconnect()   // Element removed from DOM
```
