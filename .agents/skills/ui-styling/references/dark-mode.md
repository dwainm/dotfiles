# Dark Mode

Implementing dark mode with Tailwind and DaisyUI.

## Tailwind Dark Mode

### Class Strategy (Recommended)

```javascript
// config/tailwind.config.js
module.exports = {
  darkMode: 'class',
  // ...
}
```

```html
<!-- Toggle dark mode on html element -->
<html class="dark">
  <body class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
    <!-- Content -->
  </body>
</html>
```

### Stimulus Controller

```javascript
// app/javascript/controllers/theme_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.applyTheme(this.currentTheme)
  }

  toggle() {
    const newTheme = this.currentTheme === "dark" ? "light" : "dark"
    localStorage.setItem("theme", newTheme)
    this.applyTheme(newTheme)
  }

  applyTheme(theme) {
    if (theme === "dark") {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }

  get currentTheme() {
    return localStorage.getItem("theme") ||
      (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
  }
}
```

```erb
<%# Toggle button %>
<button data-controller="theme" data-action="theme#toggle"
        class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800">
  <svg class="hidden dark:block w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
          d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 
             0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
  </svg>
  <svg class="block dark:hidden w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
          d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
  </svg>
</button>
```

### Dark Variants

```html
<!-- Background and text -->
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  
<!-- Borders -->
<div class="border-gray-200 dark:border-gray-700">

<!-- Form inputs -->
<input class="bg-white dark:bg-gray-800 border-gray-300 dark:border-gray-600
              text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500">

<!-- Buttons -->
<button class="bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600">

<!-- Shadows (often reduced in dark mode) -->
<div class="shadow-lg dark:shadow-gray-900/50">
```

## DaisyUI Dark Mode

### Automatic Theme Switching

```javascript
// config/tailwind.config.js
module.exports = {
  plugins: [require('daisyui')],
  daisyui: {
    themes: ["light", "dark"],
    darkTheme: "dark",
  },
}
```

```erb
<%# DaisyUI handles dark variants automatically -->
<html data-theme="light" data-controller="theme">
  
<%# Toggle %>
<label class="swap swap-rotate">
  <input type="checkbox" data-action="change->theme#toggleDaisy" />
  
  <%# Sun icon %>
  <svg class="swap-on fill-current w-6 h-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
    <path d="M5.64,17l-.71.71a1,1,0,0,0,0,1.41,1,1,0,0,0,1.41,0l.71-.71A1,1,0,0,0,5.64,17ZM5,12a1,1,0,0,0-1-1H3a1,1,0,0,0,0,2H4A1,1,0,0,0,5,12Zm7-7a1,1,0,0,0,1-1V3a1,1,0,0,0-2,0V4A1,1,0,0,0,12,5ZM5.64,7.05a1,1,0,0,0,.7.29,1,1,0,0,0,.71-.29,1,1,0,0,0,0-1.41l-.71-.71A1,1,0,0,0,4.93,6.34Zm12,.29a1,1,0,0,0,.7-.29l.71-.71a1,1,0,1,0-1.41-1.41L17,5.64a1,1,0,0,0,0,1.41A1,1,0,0,0,17.66,7.34ZM21,11H20a1,1,0,0,0,0,2h1a1,1,0,0,0,0-2Zm-9,8a1,1,0,0,0-1,1v1a1,1,0,0,0,2,0V20A1,1,0,0,0,12,19ZM18.36,17A1,1,0,0,0,17,18.36l.71.71a1,1,0,0,0,1.41,0,1,1,0,0,0,0-1.41ZM12,6.5A5.5,5.5,0,1,0,17.5,12,5.51,5.51,0,0,0,12,6.5Zm0,9A3.5,3.5,0,1,1,15.5,12,3.5,3.5,0,0,1,12,15.5Z"/>
  </svg>
  
  <%# Moon icon %>
  <svg class="swap-off fill-current w-6 h-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
    <path d="M21.64,13a1,1,0,0,0-1.05-.14,8.05,8.05,0,0,1-3.37.73A8.15,8.15,0,0,1,9.08,5.49a8.59,8.59,0,0,1,.25-2A1,1,0,0,0,8,2.36,10.14,10.14,0,1,0,22,14.05,1,1,0,0,0,21.64,13Zm-9.5,6.69A8.14,8.14,0,0,1,7.08,5.22v.27A10.15,10.15,0,0,0,17.22,15.63a9.79,9.79,0,0,0,2.1-.22A8.11,8.11,0,0,1,12.14,19.73Z"/>
  </svg>
</label>
```

```javascript
// DaisyUI theme toggle
toggleDaisy(event) {
  const theme = event.target.checked ? "dark" : "light"
  document.documentElement.setAttribute("data-theme", theme)
  localStorage.setItem("theme", theme)
}
```

### DaisyUI Semantic Colors

DaisyUI handles dark mode automatically with semantic colors:

```html
<%# These adapt automatically to the current theme -->
<div class="bg-base-100 text-base-content">Content</div>
<div class="bg-primary text-primary-content">Primary</div>
<div class="bg-secondary text-secondary-content">Secondary</div>
<div class="bg-accent text-accent-content">Accent</div>
<div class="bg-neutral text-neutral-content">Neutral</div>
```

### DaisyUI Semantic Scale

```
bg-base-100      - Main background
bg-base-200      - Slightly different background
bg-base-300      - Borders, dividers

base-content     - Main text
primary-content  - Text on primary bg
secondary-content - Text on secondary bg
```

## System Preference

### CSS (no JS)

```css
@media (prefers-color-scheme: dark) {
  :root {
    --bg-color: #1a1a1a;
    --text-color: #ffffff;
  }
}
```

### Tailwind (with class strategy)

```javascript
// Initialize from system preference
if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
  document.documentElement.classList.add('dark')
}
```

## Key Points

- Use `darkMode: 'class'` for manual control
- DaisyUI semantic colors handle dark mode automatically
- Always store user preference in localStorage
- Respect system preference as default
- Use `dark:` prefix for Tailwind dark variants
- Test both modes thoroughly
