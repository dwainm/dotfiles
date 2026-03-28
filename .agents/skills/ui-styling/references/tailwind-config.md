# Tailwind Configuration

## Rails 8 Setup

```bash
# New Rails 8 app with Tailwind
rails new myapp --css tailwind

# Existing app
./bin/bundle add tailwindcss-rails
./bin/rails tailwindcss:install
```

## Basic Configuration

```javascript
// config/tailwind.config.js
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
```

## With DaisyUI

```javascript
// config/tailwind.config.js
module.exports = {
  content: [
    './app/views/**/*.{erb,html}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
  ],
  plugins: [
    require('@tailwindcss/forms'),
    require('daisyui'),
  ],
  daisyui: {
    themes: ["light", "dark", "emerald"],
    darkTheme: "dark",
    base: true,
    styled: true,
    utils: true,
  },
}
```

## Content Paths

Always include these paths for Rails:

```javascript
content: [
  // Views
  './app/views/**/*.{erb,haml,slim}',
  
  // Helpers
  './app/helpers/**/*.rb',
  
  // JavaScript
  './app/javascript/**/*.js',
  
  // Static HTML
  './public/*.html',
]
```

## Theme Extensions

```javascript
theme: {
  extend: {
    // Colors
    colors: {
      brand: {
        50: '#fdf4ff',
        500: '#a855f7',
        900: '#581c87',
      }
    },
    
    // Spacing
    spacing: {
      '128': '32rem',
    },
    
    // Font sizes
    fontSize: {
      '2xs': ['0.625rem', { lineHeight: '0.75rem' }],
    },
    
    // Border radius
    borderRadius: {
      '4xl': '2rem',
    },
    
    // Animations
    animation: {
      'fade-in': 'fadeIn 0.3s ease-out',
      'slide-up': 'slideUp 0.3s ease-out',
    },
    keyframes: {
      fadeIn: {
        '0%': { opacity: '0' },
        '100%': { opacity: '1' },
      },
      slideUp: {
        '0%': { transform: 'translateY(10px)', opacity: '0' },
        '100%': { transform: 'translateY(0)', opacity: '1' },
      },
    },
  },
}
```

## Plugins

```javascript
plugins: [
  // Form reset styles
  require('@tailwindcss/forms'),
  
  // Typography plugin
  require('@tailwindcss/typography'),
  
  // DaisyUI components
  require('daisyui'),
  
  // Custom plugin
  function({ addComponents, theme }) {
    addComponents({
      '.btn-gradient': {
        background: `linear-gradient(135deg, ${theme('colors.primary.500')}, ${theme('colors.primary.700')})`,
      },
    })
  }
]
```

## Production Optimization

```javascript
// config/tailwind.config.js
module.exports = {
  // ...
  purge: {
    enabled: process.env.RAILS_ENV === 'production',
    content: [
      './app/views/**/*.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
    ],
  },
}
```

## Key Points

- Always include all content paths for Rails
- Use `extend` to add to defaults, don't override
- DaisyUI adds significant value for common components
- Configure purge for production bundle size
