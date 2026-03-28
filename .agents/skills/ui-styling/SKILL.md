---
name: ui-styling
description: Tailwind CSS and DaisyUI expert for Rails 8 - utility-first patterns, component styling, responsive design, and theming
metadata:
  tags: tailwind, daisyui, css, styling, components, responsive, dark-mode
---

## When to use

Use this skill for:
- Tailwind CSS configuration and utility patterns
- DaisyUI component usage and customization
- Responsive design and mobile-first layouts
- Dark mode implementation
- Form styling and validation states
- Component extraction decisions

## How to use

This skill is organized into reference files by topic:

- [references/tailwind-config.md](references/tailwind-config.md) - Configuration, content paths
- [references/utility-patterns.md](references/utility-patterns.md) - Common utility combinations
- [references/daisyui-components.md](references/daisyui-components.md) - Buttons, cards, forms, etc.
- [references/responsive-design.md](references/responsive-design.md) - Breakpoints, layouts
- [references/dark-mode.md](references/dark-mode.md) - Theme toggling, dark variants
- [references/form-styling.md](references/form-styling.md) - Inputs, validation states

Read only the reference file relevant to your current task.

---

## Quick Reference

### Utility vs Component Decision

| Scenario | Approach |
|----------|----------|
| One-off styling | Utility classes |
| Repeated 2-3 times | Keep utilities |
| Repeated 4+ times | Extract component |
| Complex interactive state | Stimulus + utilities |
| Design system element | `@apply` component |

### Breakpoints (Mobile-First)

```
sm: 640px   (min-width)
md: 768px
lg: 1024px
xl: 1280px
2xl: 1536px
```

### DaisyUI Common Components

```erb
<%= link_to "Save", path, class: "btn btn-primary" %>
<%= link_to "Cancel", path, class: "btn btn-ghost" %>

<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">Title</h2>
  </div>
</div>

<div class="alert alert-success">
  <span>Message saved!</span>
</div>
```
