# Stimulus Advanced Patterns

## Outlets (Cross-Controller Communication)

Connect controllers to each other:

```html
<div data-controller="modal" data-modal-id-value="1">
  <dialog data-modal-target="dialog">
    <div data-controller="form" data-form-modal-outlet="[data-controller='modal']">
      <!-- This form can communicate with its parent modal -->
    </div>
  </dialog>
</div>
```

```javascript
// app/javascript/controllers/form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["modal"]

  submitSuccess() {
    // Close parent modal on successful submit
    this.modalOutlet.close()
  }
}
```

```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]
  static values = { id: Number }

  close() {
    this.dialogTarget.close()
  }

  open() {
    this.dialogTarget.showModal()
  }
}
```

## useMutation (External Libraries)

```javascript
import { Controller } from "@hotwired/stimulus"
import { useMutation } from "stimulus-use"

export default class extends Controller {
  connect() {
    useMutation(this, { 
      attributes: true, 
      childList: true,
      subtree: true 
    })
  }

  mutate(entries) {
    entries.forEach(entry => {
      if (entry.attributeName === 'busy') {
        this.handleBusyChange(entry.target)
      }
    })
  }
}
```

## useIntersectionObserver (Lazy Loading)

```javascript
import { Controller } from "@hotwired/stimulus"
import { useIntersection } from "stimulus-use"

export default class extends Controller {
  connect() {
    useIntersection(this, {
      threshold: 0.1,
      rootMargin: '100px'
    })
  }

  intersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        this.load()
      }
    })
  }
}
```

## useResizeObserver (Responsive)

```javascript
import { Controller } from "@hotwired/stimulus"
import { useResize } from "stimulus-use"

export default class extends Controller {
  connect() {
    useResize(this)
  }

  resize({ width, height }) {
    this.adjustLayout(width)
  }
}
```

## useClickOutside

```javascript
import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from "stimulus-use"

export default class extends Controller {
  connect() {
    useClickOutside(this)
  }

  clickOutside(event) {
    this.close()
  }

  click(event) {
    event.stopPropagation()
  }
}
```

## Web Share API

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String,
    text: String,
    url: String
  }

  async share() {
    if (navigator.share) {
      try {
        await navigator.share({
          title: this.titleValue,
          text: this.textValue,
          url: this.urlValue || window.location.href
        })
      } catch (err) {
        console.log('Share canceled')
      }
    } else {
      // Fallback: copy to clipboard
      await navigator.clipboard.writeText(window.location.href)
      this.showCopiedMessage()
    }
  }
}
```

## Auto-Sort with Drag and Drop

```javascript
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list"]
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      onEnd: this.persist.bind(this)
    })
  }

  async persist(event) {
    const item = event.item
    const newIndex = event.newIndex

    await fetch(this.urlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        id: item.dataset.id,
        position: newIndex
      })
    })
  }
}
```

## Target Callbacks

React when targets are added/removed:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  itemTargetConnected(element) {
    console.log("Item added:", element)
    this.highlightNewItem(element)
  }

  itemTargetDisconnected(element) {
    console.log("Item removed:", element)
    this.updateEmptyState()
  }
}
```

## Keyboard Events 101

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleKeydown(event) {
    switch(event.key) {
      case 'Escape':
        this.close()
        break
      case 'Enter':
        if (event.metaKey || event.ctrlKey) {
          this.submit()
        }
        break
      case 'ArrowDown':
        event.preventDefault()
        this.focusNext()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.focusPrevious()
        break
    }
  }
}
```

## Core Web Vitals

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.observeLCP()
    this.observeCLS()
    this.observeINP()
  }

  observeLCP() {
    new PerformanceObserver((list) => {
      const entries = list.getEntries()
      const lastEntry = entries[entries.length - 1]
      console.log('LCP:', lastEntry.startTime)
    }).observe({ entryTypes: ['largest-contentful-paint'] })
  }
}
```

## Controller Best Practices

1. **Keep controllers small** - One responsibility per controller
2. **Use targets over querySelector** - More declarative, auto-updates
3. **Clean up in disconnect()** - Remove timers, observers, listeners
4. **Use values for configuration** - Keep HTML as the source of truth
5. **Handle missing targets gracefully** - Use `has*Target` checks

## Key Points

- Outlets enable parent-child controller relationships
- stimulus-use provides common observer patterns
- Target callbacks react to DOM changes automatically
- Always clean up resources in `disconnect()`
