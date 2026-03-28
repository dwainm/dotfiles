# Responsive Design

Mobile-first responsive patterns with Tailwind.

## Breakpoints

```
Default: 0px+      (mobile first)
sm: 640px+         (small tablets)
md: 768px+         (tablets)
lg: 1024px+         (desktop)
xl: 1280px+         (large desktop)
2xl: 1536px+        (extra large)
```

## Mobile-First Approach

Start with mobile, add complexity at larger screens:

```html
<!-- Base = mobile, sm/md/lg = larger screens -->
<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
  <!-- Mobile: 1 column
       sm+: 2 columns  
       lg+: 3 columns -->
</div>
```

## Common Layout Patterns

### Sidebar Layout
```html
<div class="lg:grid lg:grid-cols-12 lg:gap-8">
  <!-- Sidebar: hidden on mobile, 3 cols on desktop -->
  <aside class="hidden lg:block lg:col-span-3">
    <nav>Sidebar content</nav>
  </aside>
  
  <!-- Main: full width mobile, 9 cols desktop -->
  <main class="lg:col-span-9">
    Main content
  </main>
</div>
```

### Stack to Side-by-Side
```html
<!-- Mobile: stacked, Desktop: side by side -->
<div class="flex flex-col md:flex-row gap-4">
  <div class="md:w-1/3">Sidebar</div>
  <div class="md:w-2/3">Main</div>
</div>
```

### Responsive Card Grid
```html
<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
  <% @items.each do |item| %>
    <div class="card">
      <!-- Card content -->
    </div>
  <% end %>
</div>
```

### Responsive Table
```html
<!-- Horizontal scroll on mobile -->
<div class="overflow-x-auto">
  <table class="table w-full">
    <!-- Table content -->
  </table>
</div>
```

### Responsive Navigation
```html
<!-- Mobile: hamburger menu, Desktop: horizontal nav -->
<nav class="hidden md:flex gap-4">
  <%= link_to "Home", root_path, class: "nav-link" %>
  <%= link_to "About", about_path, class: "nav-link" %>
</nav>

<button class="md:hidden" data-controller="mobile-menu">
  Menu
</button>
```

## Container Queries

For component-based responsive design:

```css
/* Tailwind plugin required */
@tailwind container;
```

```html
<div class="@container">
  <div class="grid grid-cols-1 @md:grid-cols-2 @lg:grid-cols-3">
    <!-- Responsive to container, not viewport -->
  </div>
</div>
```

## Responsive Typography

```html
<h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold">
  Responsive Heading
</h1>

<p class="text-sm sm:text-base lg:text-lg">
  Responsive body text
</p>
```

## Responsive Spacing

```html
<div class="p-4 sm:p-6 lg:p-8">
  <!-- Padding grows with screen size -->
</div>

<div class="space-y-2 sm:space-y-4 lg:space-y-6">
  <!-- Spacing between children -->
</div>
```

## Responsive Hiding/Showing

```html
<!-- Hide on mobile, show on desktop -->
<div class="hidden md:block">Desktop only</div>

<!-- Show on mobile, hide on desktop -->
<div class="md:hidden">Mobile only</div>

<!-- Show/hide at specific breakpoints -->
<div class="hidden sm:block lg:hidden">Tablet only</div>
```

## Touch Targets

Ensure minimum 44px touch targets on mobile:

```html
<button class="p-3 min-h-[44px] min-w-[44px]">
  Touch-friendly button
</button>
```

## Responsive Forms

```html
<%= form_with model: @budget, 
    class: "grid grid-cols-1 md:grid-cols-2 gap-4" do |f| %>
  
  <div class="md:col-span-2">
    <%= f.text_field :name, class: "input w-full" %>
  </div>
  
  <%= f.select :currency, options, {}, class: "select w-full" %>
  <%= f.number_field :amount, class: "input w-full" %>
  
  <div class="md:col-span-2">
    <%= f.submit class: "btn btn-primary w-full md:w-auto" %>
  </div>
<% end %>
```

## Responsive Images

```html
<%= image_tag "photo.jpg",
    class: "w-full h-auto object-cover",
    srcset: "photo-400.jpg 400w, photo-800.jpg 800w, photo-1200.jpg 1200w",
    sizes: "(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw" %>
```

## Key Points

- Always design mobile-first (base styles are mobile)
- Use `sm:`, `md:`, `lg:` prefixes for larger screens
- Test at all breakpoints: 320px, 768px, 1024px, 1440px
- Touch targets minimum 44x44px on mobile
- Use `overflow-x-auto` for tables on mobile
