# Turbo Frames

Turbo Frames scope navigation to specific portions of the page.

## Basic Usage

```erb
<%# app/views/budgets/show.html.erb %>
<h1><%= @budget.name %></h1>

<%= turbo_frame_tag "budget_details" do %>
  <dl>
    <dt>Currency</dt>
    <dd><%= @budget.currency %></dd>
  </dl>
  <%= link_to "Edit", edit_budget_path(@budget) %>
<% end %>

<%# app/views/budgets/edit.html.erb %>
<%= turbo_frame_tag "budget_details" do %>
  <%= render "form", budget: @budget %>
<% end %>
```

## Loading Spinners

### Solution 1: Stimulus with MutationObserver

```html
<turbo-frame id="content" src="/page1" data-controller="frame-spinner">
  <template data-frame-spinner-target="placeholder">
    <div class="spinner">Loading...</div>
  </template>
</turbo-frame>
```

```javascript
import { Controller } from '@hotwired/stimulus';
import { useMutation } from 'stimulus-use';

export default class extends Controller {
  static targets = ['placeholder'];

  connect() {
    useMutation(this, { attributes: true });
    this.templateNode = this.placeholderTarget.content.cloneNode(true);

    if (this.element.hasAttribute('busy')) {
      this.#renderPlaceholder();
    }
  }

  mutate(entries) {
    entries
      .filter(e => e.attributeName === 'busy')
      .forEach(() => this.#renderPlaceholder());
  }

  #renderPlaceholder() {
    if (this.element.hasChildNodes()) {
      this.element.firstChild.replaceWith(this.templateNode.cloneNode(true));
    } else {
      this.element.appendChild(this.templateNode.cloneNode(true));
    }
  }
}
```

### Solution 2: CSS Only (Simple Text)

```css
turbo-frame[busy] {
  font-size: 0;
  * { display: none; }
  &::after {
    font-size: 1rem;
    content: 'Loading...';
  }
}
```

## Lazy Loading

```erb
<%# Load content when frame becomes visible %>
<%= turbo_frame_tag "transactions", 
      src: budget_transactions_path(@budget), 
      loading: :lazy do %>
  <p>Loading transactions...</p>
<% end %>
```

## Targeting Frames

```erb
<%# Link targets a different frame %>
<%= link_to "Edit", edit_budget_path(@budget), 
      data: { turbo_frame: "modal" } %>

<%# Target the whole page (break out of frame) %>
<%= link_to "View All", budgets_path, 
      data: { turbo_frame: "_top" } %>
```

## Inline Editing

```erb
<%# Display view %>
<%= turbo_frame_tag "title-editor" do %>
  <%= link_to @post.title, edit_post_path(@post) %>
<% end %>

<%# Edit view (returned by edit action) %>
<%= turbo_frame_tag "title-editor" do %>
  <form action="<%= post_path(@post) %>" method="post">
    <input type="hidden" name="_method" value="patch">
    <input type="text" name="post[title]" value="<%= @post.title %>" 
           autofocus id="post_title">
  </form>
<% end %>
```

```javascript
// Auto-submit on blur and select text on focus
document.addEventListener('turbo:frame-render', () => {
  const input = document.querySelector('#post_title');
  if (!input) return;
  
  input.select(); // Select all text for easy replacement
  
  input.addEventListener('focusout', (e) => {
    e.target.closest('form').requestSubmit();
  });
});
```

## Modals

```erb
<%# In layout %>
<%= turbo_frame_tag "modal" %>

<%# Link opens modal %>
<%= link_to "New Line Item", new_line_item_path, 
      data: { turbo_frame: "modal" } %>

<%# Modal view %>
<%= turbo_frame_tag "modal" do %>
  <div data-controller="modal">
    <dialog data-modal-target="dialog" open>
      <h2>New Line Item</h2>
      <%= render "form", line_item: @line_item %>
      <form method="dialog">
        <button>Cancel</button>
      </form>
    </dialog>
  </div>
<% end %>
```

```javascript
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['dialog'];

  connect() {
    this.dialogTarget.showModal();
  }

  disconnect() {
    this.dialogTarget.close();
  }

  close() {
    this.dialogTarget.close();
  }
}
```

## Pagination

```erb
<%= turbo_frame_tag "items" do %>
  <%= render @items %>
  
  <%= link_to "Next", items_path(page: @items.next_page),
        data: { turbo_frame: "items", turbo_action: "advance" } %>
<% end %>
```

## Tabbed Navigation

```erb
<div role="tablist" class="tabs">
  <%= link_to "Overview", budget_path(@budget),
        class: "tab #{current_page?(budget_path(@budget)) ? 'tab-active' : ''}",
        data: { turbo_frame: "budget_content" } %>
  <%= link_to "Transactions", budget_transactions_path(@budget),
        class: "tab #{current_page?(...) ? 'tab-active' : ''}",
        data: { turbo_frame: "budget_content" } %>
</div>

<%= turbo_frame_tag "budget_content" do %>
  <%= yield %>
<% end %>
```

## Scroll Position

Restore scroll position on back/forward:

```javascript
document.addEventListener('turbo:before-render', (event) => {
  event.detail.newBody.querySelectorAll('[data-scroll-position]').forEach(el => {
    const position = sessionStorage.getItem(`scroll:${el.id}`);
    if (position) {
      el.scrollTop = parseInt(position);
    }
  });
});
```

## Key Points

- Always use matching `turbo_frame_tag` IDs
- Use `[busy]` attribute for loading states
- Handle `turbo:frame-render` for focus management
- Keep frame state in URL for back/forward support
