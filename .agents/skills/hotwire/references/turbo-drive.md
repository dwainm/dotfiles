# Turbo Drive

Turbo Drive accelerates page navigation by intercepting link clicks and form submissions.

## Basic Usage

Turbo Drive is automatic. All links become AJAX by default:

```erb
<a href="/budgets">View Budgets</a>
```

### Disable for Specific Links

```erb
<%# External links, downloads %>
<a href="/external" data-turbo="false">External Link</a>
<a href="/download.pdf" data-turbo="false">Download PDF</a>
```

### Disable for Forms

```erb
<%# File uploads, legacy forms %>
<%= form_with model: @budget, data: { turbo: false } do |f| %>
  <%= f.file_field :import_file %>
<% end %>
```

## Form Activity Indicators

Show user feedback during slow form submissions:

```javascript
// Show "Saving..." on submit start
document.addEventListener('turbo:submit-start', (e) => {
  const form = e.target;
  form.querySelector('[type="submit"]').disabled = true;
  form.classList.add('submitting');
  form.querySelector('#status').textContent = 'Saving...';
});

// Update to "Saved." on completion
document.addEventListener('turbo:submit-end', (e) => {
  const form = e.target;
  form.querySelector('[type="submit"]').disabled = false;
  form.classList.remove('submitting');
  form.querySelector('#status').textContent = 'Saved.';
});
```

```css
form.submitting [type="submit"] {
  opacity: 0.5;
  cursor: wait;
}
```

### With Render Pausing

Add delays for status transitions to be perceivable:

```javascript
document.addEventListener('turbo:before-render', (event) => {
  event.preventDefault();
  
  setTimeout(() => {
    event.detail.resume();
  }, 500); // Minimum visible time
});
```

## Progress Bar

Customize the progress bar:

```css
.turbo-progress-bar {
  height: 3px;
  background-color: theme('colors.primary.600');
}
```

## Page Transitions

Intercept renders for custom transitions:

```javascript
document.addEventListener('turbo:before-render', (event) => {
  event.preventDefault();
  
  // Start exit animation
  document.body.classList.add('transitioning-out');
  
  setTimeout(() => {
    event.detail.resume();
    document.body.classList.remove('transitioning-out');
    document.body.classList.add('transitioning-in');
  }, 300);
});
```

## Cache Lifecycle

Clean transient UI state before cache snapshots:

```javascript
document.addEventListener('turbo:before-cache', () => {
  // Close dropdowns, modals, etc.
  document.querySelectorAll('[data-dropdown-open]').forEach(el => {
    el.removeAttribute('data-dropdown-open');
  });
});
```

## Instant Click

Prefetch on hover (use sparingly):

```javascript
document.addEventListener('mouseover', (e) => {
  if (e.target.matches('a[href^="/"]')) {
    Turbo.visit(e.target.href, { action: 'advance' });
  }
});
```

## Key Points

- Use `data-turbo="false"` for non-Turbo interactions
- Always disable inputs during submit to prevent race conditions
- Keep submit locking/unlocking symmetric
- Gate animations for previews and cache restores
