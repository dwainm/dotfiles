# Integration Patterns

Combining Hotwire technologies effectively.

## When to Use Each Technology

| Need | Solution |
|------|----------|
| Fast page navigation | Turbo Drive (automatic) |
| Update part of page without JS | Turbo Frames |
| Real-time updates from server | Turbo Streams |
| Complex UI interactions | Stimulus |
| Loading feedback | Stimulus + Turbo events |
| Form validation | Turbo Frames + Stimulus |
| Modals, dropdowns | Stimulus + (optional) Turbo Frames |

## Modal with Turbo Frame

```erb
<%# In layout %>
<%= turbo_frame_tag "modal" %>

<%# Link opens modal %>
<%= link_to "New Budget", new_budget_path, 
      data: { turbo_frame: "modal" } %>

<%# Modal content (new.html.erb) %>
<%= turbo_frame_tag "modal" do %>
  <div data-controller="modal" data-action="keydown.esc->modal#close">
    <dialog data-modal-target="dialog" data-action="click->modal#backdropClose">
      <%= render "form", budget: @budget %>
    </dialog>
  </div>
<% end %>
```

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.dialogTarget.showModal()
    this.preventBodyScroll()
  }

  disconnect() {
    this.dialogTarget.close()
    this.restoreBodyScroll()
  }

  close() {
    this.dialogTarget.close() // Triggers disconnect, removes from DOM
  }

  backdropClose(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }

  preventBodyScroll() {
    document.body.style.overflow = 'hidden'
  }

  restoreBodyScroll() {
    document.body.style.overflow = ''
  }
}
```

## Live Search with Turbo Frame

```erb
<%# app/views/transactions/index.html.erb %>
<div data-controller="search">
  <input type="search"
         data-search-target="input"
         data-action="input->search#query"
         placeholder="Search transactions...">

  <%= turbo_frame_tag "transactions_list", 
        data: { search_target: "frame" } do %>
    <%= render @transactions %>
  <% end %>
</div>
```

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "frame"]

  query() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const url = new URL(window.location)
      url.searchParams.set("q", this.inputTarget.value)
      this.frameTarget.src = url.toString()
    }, 300)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
```

## Infinite Scroll

```erb
<%= turbo_frame_tag "items" do %>
  <%= render @items %>
  
  <% if @items.next_page %>
    <%= turbo_frame_tag "items-page-#{@items.next_page}",
          src: items_path(page: @items.next_page),
          loading: :lazy,
          data: { controller: "autoclick" } %>
  <% end %>
<% end %>
```

```javascript
import { Controller } from "@hotwired/stimulus"
import { useIntersection } from "stimulus-use"

export default class extends Controller {
  connect() {
    useIntersection(this, { threshold: 0 })
  }

  intersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        // Frame is visible, Turbo will auto-load via lazy
        // Or manually: this.element.querySelector('a')?.click()
      }
    })
  }
}
```

## Tabs with History

```erb
<div class="tabs">
  <%= link_to "Overview", budget_path(@budget),
        class: "tab #{current_tab?(:overview)}",
        data: { turbo_frame: "tab_content", turbo_action: "advance" } %>
  <%= link_to "Transactions", budget_transactions_path(@budget),
        class: "tab #{current_tab?(:transactions)}",
        data: { turbo_frame: "tab_content", turbo_action: "advance" } %>
</div>

<%= turbo_frame_tag "tab_content" do %>
  <%= yield %>
<% end %>
```

```ruby
# Helper
def current_tab?(name)
  case name
  when :overview
    current_page?(budget_path(@budget))
  when :transactions
    request.path.include?('/transactions')
  end ? 'tab-active' : ''
end
```

## Drag and Drop with SortableJS

```erb
<div data-controller="sortable" data-sortable-url-value="<%= sort_items_path %>">
  <div data-sortable-target="list">
    <% @items.each do |item| %>
      <div data-id="<%= item.id %>" class="sortable-item">
        <%= item.name %>
      </div>
    <% end %>
  </div>
</div>
```

```javascript
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list"]
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      ghostClass: 'sortable-ghost',
      onEnd: this.persist.bind(this)
    })
  }

  async persist(event) {
    const positions = this.sortable.toArray()
    
    await fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ positions })
    })
  }
}
```

## Combobox with Real-Time Data

```erb
<div data-controller="combobox">
  <input type="text"
         data-combobox-target="input"
         data-action="input->combobox#search focus->combobox#open"
         placeholder="Select category...">
  
  <%= turbo_frame_tag "combobox_results",
        data: { combobox_target: "results" } %>
</div>

<%= turbo_stream_from "categories" %>
```

## Multi-Select with Turbo Streams

```erb
<div data-controller="selection">
  <div data-selection-target="items">
    <% @items.each do |item| %>
      <div data-id="<%= item.id %>">
        <input type="checkbox" 
               data-action="change->selection#toggle"
               data-id="<%= item.id %>">
        <%= item.name %>
      </div>
    <% end %>
  </div>
  
  <button data-action="click->selection#bulkDelete"
          data-selection-target="bulkAction"
          class="hidden">
    Delete Selected (<span data-selection-target="count">0</span>)
  </button>
</div>
```

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["items", "bulkAction", "count"]
  
  connect() {
    this.selected = new Set()
  }

  toggle(event) {
    const id = event.target.dataset.id
    
    if (event.target.checked) {
      this.selected.add(id)
    } else {
      this.selected.delete(id)
    }
    
    this.updateUI()
  }

  updateUI() {
    const count = this.selected.size
    this.countTarget.textContent = count
    this.bulkActionTarget.classList.toggle('hidden', count === 0)
  }

  bulkDelete() {
    // Send to server via fetch or form
    fetch('/items/bulk_destroy', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ ids: Array.from(this.selected) })
    })
  }
}
```

## Key Points

- Turbo Drive handles navigation automatically
- Use Frames for partial page updates without custom JS
- Use Streams for real-time server-driven updates
- Use Stimulus for everything else (complex interactions, third-party libs)
- Combine them: Frame + Stimulus controller = rich interactions
- Keep progressive enhancement in mind - it should work without JS
