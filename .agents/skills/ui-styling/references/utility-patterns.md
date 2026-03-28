# Utility Patterns

Common Tailwind utility combinations for Rails applications.

## Layout Patterns

### Centered Container
```html
<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
  <!-- Content -->
</div>
```

### Sidebar Layout
```html
<div class="lg:grid lg:grid-cols-12 lg:gap-8">
  <aside class="lg:col-span-3">
    <!-- Sidebar -->
  </aside>
  <main class="mt-8 lg:col-span-9 lg:mt-0">
    <!-- Main content -->
  </main>
</div>
```

### Card Grid
```html
<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
  <!-- Cards -->
</div>
```

### Flex Center
```html
<div class="flex items-center justify-center min-h-screen">
  <!-- Centered content -->
</div>
```

## Component Patterns

### Button (Primary)
```html
<button class="inline-flex items-center justify-center rounded-md bg-blue-600 
               px-4 py-2 text-sm font-medium text-white shadow-sm 
               hover:bg-blue-700 focus:outline-none focus:ring-2 
               focus:ring-blue-500 focus:ring-offset-2 
               disabled:opacity-50 disabled:cursor-not-allowed
               transition-colors">
  Save
</button>
```

### Button (Secondary)
```html
<button class="inline-flex items-center justify-center rounded-md bg-white 
               px-4 py-2 text-sm font-medium text-gray-700 shadow-sm 
               border border-gray-300 hover:bg-gray-50 
               focus:outline-none focus:ring-2 focus:ring-blue-500 
               focus:ring-offset-2">
  Cancel
</button>
```

### Input Field
```html
<input type="text" class="block w-full rounded-md border-gray-300 
                          shadow-sm focus:border-blue-500 focus:ring-blue-500 
                          sm:text-sm disabled:bg-gray-100 disabled:text-gray-500"
       placeholder="Enter value...">
```

### Card
```html
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm 
            hover:shadow-md transition-shadow">
  <h3 class="text-lg font-semibold text-gray-900">Title</h3>
  <p class="mt-2 text-sm text-gray-600">Description</p>
</div>
```

### Alert
```html
<!-- Success -->
<div class="rounded-md bg-green-50 p-4 border border-green-200">
  <div class="flex">
    <div class="flex-shrink-0">
      <svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
      </svg>
    </div>
    <div class="ml-3">
      <p class="text-sm font-medium text-green-800">Success message</p>
    </div>
  </div>
</div>

<!-- Error -->
<div class="rounded-md bg-red-50 p-4 border border-red-200">
  <p class="text-sm font-medium text-red-800">Error message</p>
</div>
```

### Badge
```html
<span class="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 
             text-xs font-medium text-blue-800">
  Active
</span>
```

## Text Patterns

### Heading Hierarchy
```html
<h1 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
  Page Title
</h1>
<h2 class="text-2xl font-semibold text-gray-900">
  Section Title
</h2>
<h3 class="text-lg font-medium text-gray-900">
  Subsection
</h3>
```

### Body Text
```html
<p class="text-base text-gray-600 leading-relaxed">
  Body paragraph with comfortable line height.
</p>
<p class="text-sm text-gray-500">
  Secondary/muted text.
</p>
<p class="text-xs text-gray-400 uppercase tracking-wide">
  Label text
</p>
```

### Truncate
```html
<p class="truncate">
  Very long text that will be truncated with ellipsis...
</p>

<p class="line-clamp-3">
  Text that will be clamped to 3 lines with ellipsis...
</p>
```

## Interactive States

### Hover/Focus
```html
<button class="bg-blue-600 hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 
               focus:ring-offset-2 focus:outline-none">
```

### Active/Disabled
```html
<button class="active:bg-blue-800 disabled:opacity-50 disabled:cursor-not-allowed">
```

### Group Hover
```html
<div class="group cursor-pointer">
  <div class="group-hover:bg-gray-50">
    Content
  </div>
</div>
```

## Extraction with @apply

```css
/* app/assets/stylesheets/components/buttons.css */
@layer components {
  .btn {
    @apply inline-flex items-center justify-center rounded-md px-4 py-2
           text-sm font-medium transition-colors focus:outline-none
           focus:ring-2 focus:ring-offset-2 disabled:opacity-50
           disabled:pointer-events-none;
  }

  .btn-primary {
    @apply btn bg-blue-600 text-white hover:bg-blue-700
           focus:ring-blue-500;
  }

  .btn-secondary {
    @apply btn bg-white text-gray-700 border border-gray-300
           hover:bg-gray-50 focus:ring-blue-500;
  }

  .btn-danger {
    @apply btn bg-red-600 text-white hover:bg-red-700
           focus:ring-red-500;
  }
}
```

## Key Points

- Prefer utilities for one-off styling
- Extract with `@apply` at 4+ repetitions
- Always include focus states for accessibility
- Use `disabled:` variants for form elements
- Keep consistent spacing (4, 6, 8 pattern)
