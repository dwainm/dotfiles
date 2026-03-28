# UX Patterns

Advanced UX patterns for better perceived performance and user feedback.

## Form Activity Indicators

Show feedback during slow form submissions:

```javascript
document.addEventListener('turbo:submit-start', (e) => {
  const form = e.target;
  form.classList.add('submitting');
  form.querySelector('[type="submit"]').disabled = true;
  
  // Show status
  const status = form.querySelector('#form-status')
  if (status) status.textContent = 'Saving...'
})

document.addEventListener('turbo:submit-end', (e) => {
  const form = e.target;
  form.classList.remove('submitting');
  form.querySelector('[type="submit"]').disabled = false;
  
  const status = form.querySelector('#form-status')
  if (status) status.textContent = 'Saved.'
})
```

```css
form.submitting {
  opacity: 0.8;
}

form.submitting [type="submit"] {
  cursor: wait;
  position: relative;
}

form.submitting [type="submit"]::after {
  content: '';
  position: absolute;
  width: 1em;
  height: 1em;
  border: 2px solid transparent;
  border-top-color: currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

## Optimistic UI with Turbo 8 Morphs

Update UI immediately, reconcile with server:

```html
<form method="post" action="/favorites" data-optimistic-form>
  <template class="optimistic-template">
    <turbo-stream action="replace" target="favorite-btn">
      <template>
        <button id="favorite-btn" disabled class="favorited">
          <!-- Inverse state (optimistic) -->
          <svg class="heart-filled">...</svg>
        </button>
      </template>
    </turbo-stream>
  </template>
  
  <button type="submit" id="favorite-btn">
    <svg class="heart-empty">...</svg>
  </button>
</form>
```

```javascript
document.querySelectorAll('form[data-optimistic-form]').forEach((form) => {
  form.addEventListener('turbo:submit-start', (e) => {
    const template = e.target.querySelector('.optimistic-template')
    document.body.appendChild(template.content.cloneNode(true))
  })
})
```

```ruby
# Controller reconciles with morph
def create
  @favorite = current_user.toggle_favorite(params[:item_id])
  
  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.refresh }
  end
end
```

## ULID-Based Optimistic Identity

Generate client-side IDs for instant creation:

```javascript
import { ulid } from 'ulid'

document.addEventListener('turbo:submit-start', (e) => {
  const form = e.target
  
  // Add optimistic ID if not present
  if (!form.querySelector('[name="optimistic_id"]')) {
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = 'optimistic_id'
    input.value = ulid()
    form.appendChild(input)
  }
})
```

## Progress Bar Customization

```css
.turbo-progress-bar {
  height: 3px;
  background: linear-gradient(90deg, #3b82f6, #8b5cf6);
  box-shadow: 0 0 10px rgba(59, 130, 246, 0.5);
}
```

## View Transitions

Smooth page transitions:

```javascript
document.addEventListener('turbo:before-render', (event) => {
  // Don't animate on restore/preview
  if (event.detail.newFrame?.dataset.turboPreview) return
  
  event.preventDefault()
  
  document.body.style.viewTransitionName = 'root'
  
  document.startViewTransition(() => {
    event.detail.resume()
  })
})
```

```css
@view-transition {
  navigation: auto;
}

::view-transition-old(root) {
  animation: fade-out 0.3s ease;
}

::view-transition-new(root) {
  animation: fade-in 0.3s ease;
}

@keyframes fade-out {
  to { opacity: 0; }
}

@keyframes fade-in {
  from { opacity: 0; }
}
```

## Loading Skeletons

```html
<div data-controller="skeleton">
  <div class="skeleton-text" data-skeleton-target="content">
    <!-- Actual content -->
  </div>
</div>
```

```css
.skeleton-text {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
  min-height: 1em;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

## Toast Notifications

```html
<div id="toasts" data-controller="toast">
  <template data-toast-target="template">
    <div class="toast" role="alert">
      <span data-toast-target="message"></span>
      <button data-action="toast#dismiss">&times;</button>
    </div>
  </template>
</div>
```

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]

  show(message, type = 'info') {
    const toast = this.templateTarget.content.cloneNode(true)
    toast.querySelector('[data-toast-target="message"]').textContent = message
    toast.firstElementChild.classList.add(`toast--${type}`)
    
    this.element.appendChild(toast)
    
    // Auto-dismiss
    setTimeout(() => {
      toast.firstElementChild?.remove()
    }, 5000)
  }
}
```

## Key Points

- Always disable inputs during submission to prevent race conditions
- Keep submit locking/unlocking symmetric between start and end events
- Gate animations/transitions for previews and cache restores
- Use optimistic UI only with clear reconciliation strategy
- View transitions add perceived polish but aren't essential
