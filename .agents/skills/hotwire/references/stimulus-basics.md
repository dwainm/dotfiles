# Stimulus Basics

Stimulus is a modest JavaScript framework for the HTML you already have.

## Controller Structure

```javascript
// app/javascript/controllers/example_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 1. Static definitions
  static targets = ["name", "output"]
  static values = { name: String }
  static classes = ["loading"]

  // 2. Lifecycle hooks
  initialize() {
    // Called once when controller is instantiated
    console.log("Controller created")
  }

  connect() {
    // Called each time element is inserted into DOM
    console.log("Connected to:", this.element)
  }

  disconnect() {
    // Called each time element is removed from DOM
    console.log("Disconnected")
  }

  // 3. Actions (called by data-action attributes)
  greet() {
    this.outputTarget.textContent = `Hello, ${this.nameTarget.value}!`
  }

  // 4. Value changed callbacks
  nameValueChanged(newValue, oldValue) {
    console.log(`Name changed from ${oldValue} to ${newValue}`)
  }
}
```

## Targets

Declare and access DOM elements:

```html
<div data-controller="hello">
  <input data-hello-target="name" type="text">
  <button data-action="click->hello#greet">Greet</button>
  <span data-hello-target="output"></span>
</div>
```

```javascript
static targets = ["name", "output"]

// Access in controller
this.nameTarget        // => <input> element
this.outputTarget     // => <span> element
this.hasNameTarget    // => true (boolean check)
this.nameTargets      // => [elements] (all matching)
```

## Values

Typed data passed from HTML to JavaScript:

```html
<div data-controller="counter"
     data-counter-count-value="0"
     data-counter-step-value="1"
     data-counter-auto-start-value="true">
  <span data-counter-target="display">0</span>
  <button data-action="click->counter#increment">+</button>
</div>
```

```javascript
static values = {
  count: { type: Number, default: 0 },
  step: { type: Number, default: 1 },
  autoStart: { type: Boolean, default: false }
}

// Access in controller
this.countValue       // => 0 (Number)
this.stepValue        // => 1 (Number)
this.autoStartValue   // => true (Boolean)

// Type coercion happens automatically
// Changed callbacks are automatic too:
countValueChanged(newValue, oldValue) {
  this.displayTarget.textContent = newValue
}
```

### Value Types

| Type | Example | JavaScript |
|------|---------|------------|
| String | `data-foo-name-value="bar"` | `"bar"` |
| Number | `data-foo-count-value="5"` | `5` |
| Boolean | `data-foo-active-value="true"` | `true` |
| Array | `data-foo-items-value='[1,2,3]'` | `[1,2,3]` |
| Object | `data-foo-config-value='{"a":1}'` | `{a: 1}` |

## Actions

Connect DOM events to controller methods:

```html
<!-- Basic click -->
<button data-action="click->modal#open">Open</button>

<!-- Multiple events -->
<input data-action="input->search#filter keydown.enter->search#submit">

<!-- Event options -->
<form data-action="submit->form#save:prevent">
  <!-- :prevent calls event.preventDefault() -->
</form>

<!-- Click outside -->
<div data-action="click@window->dropdown#close">
  <!-- @window listens on window -->
</div>
```

### Event Options

| Option | Effect |
|--------|--------|
| `:prevent` | `event.preventDefault()` |
| `:stop` | `event.stopPropagation()` |
| `:once` | Remove listener after first trigger |
| `:passive` | Add passive listener |
| `:capture` | Use capture phase |

### Action Parameters

```html
<button data-action="click->budget#selectCategory"
        data-budget-id-param="123"
        data-budget-name-param="Groceries">
  Select
</button>
```

```javascript
selectCategory(event) {
  const { id, name } = event.params
  console.log(`Selected ${name} (ID: ${id})`)
  // => Selected Groceries (ID: 123)
}
```

## CSS Classes

Toggle classes declaratively:

```html
<div data-controller="toggle"
     data-toggle-hidden-class="hidden"
     data-toggle-active-class="bg-blue-500">
  <button data-action="toggle#toggle">Toggle</button>
  <div data-toggle-target="content" class="hidden">
    Content
  </div>
</div>
```

```javascript
static classes = ["hidden", "active"]
static targets = ["content"]

toggle() {
  this.contentTarget.classList.toggle(this.hiddenClass)
}

activate() {
  this.contentTarget.classList.add(this.activeClass)
}
```

## Common Patterns

### Debounced Input

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { wait: { type: Number, default: 300 } }
  
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.waitValue)
  }
}
```

```html
<form data-controller="debounce" data-turbo-frame="results">
  <input type="search" name="q" 
         data-action="input->debounce#search"
         data-debounce-wait-value="300">
</form>
```

### Form Reset

```javascript
reset() {
  this.element.reset()
  this.element.querySelectorAll('[data-reset]').forEach(el => {
    el.textContent = ''
  })
}
```

### Focus Management

```javascript
connect() {
  this.hasFocusTarget && this.focusTarget.focus()
}

focus() {
  this.inputTarget.focus()
  this.inputTarget.select()
}
```

## Controller Naming

- Filename: `app/javascript/controllers/hello_controller.js`
- Identifier: `hello` (automatic from filename)
- HTML: `data-controller="hello"`

Multiple controllers on one element:
```html
<div data-controller="clipboard tooltip">
  <!-- Uses clipboard_controller.js and tooltip_controller.js -->
</div>
```

## Key Points

- Controllers are HTML-centric, not component-centric
- One controller per element (can have multiple)
- Targets connect automatically when DOM changes
- Values are reactive with `*ValueChanged()` callbacks
- Actions are DOM events mapped to methods
