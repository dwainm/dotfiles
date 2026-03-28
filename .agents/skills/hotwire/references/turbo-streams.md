# Turbo Streams

Turbo Streams deliver page changes as HTML fragments over WebSocket, SSE, or form responses.

## The 8 Stream Actions

```erb
<%# append - Add to end of container %>
<%= turbo_stream.append "line_items" do %>
  <%= render @line_item %>
<% end %>

<%# prepend - Add to beginning %>
<%= turbo_stream.prepend "transactions", @transaction %>

<%# replace - Replace entire element %>
<%= turbo_stream.replace @budget %>

<%# update - Replace inner HTML only %>
<%= turbo_stream.update "budget_total" do %>
  <%= number_to_currency(@budget.total) %>
<% end %>

<%# remove - Remove element %>
<%= turbo_stream.remove @line_item %>

<%# before/after - Insert around target %>
<%= turbo_stream.before "existing_item", @new_item %>
<%= turbo_stream.after "existing_item", @new_item %>

<%# morph - Morph element (Turbo 8) %>
<%= turbo_stream.morph @budget %>

<%# refresh - Full page refresh (Turbo 8) %>
<%= turbo_stream.refresh %>
```

## Controller Responses

```ruby
# app/controllers/line_items_controller.rb
def create
  @line_item = @group.line_items.build(line_item_params)

  respond_to do |format|
    if @line_item.save
      format.turbo_stream  # Renders create.turbo_stream.erb
      format.html { redirect_to @month }
    else
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "line_item_form",
          partial: "line_items/form",
          locals: { line_item: @line_item }
        )
      end
    end
  end
end
```

```erb
<%# app/views/line_items/create.turbo_stream.erb %>
<%= turbo_stream.prepend "line_items", @line_item %>
<%= turbo_stream.update "group_total", @group.total %>
<%= turbo_stream.replace "line_item_form" do %>
  <%= render "form", line_item: LineItem.new %>
<% end %>
```

## Broadcasting from Models

```ruby
# app/models/line_item.rb
class LineItem < ApplicationRecord
  after_create_commit -> { broadcast_prepend_to group, :line_items }
  after_update_commit -> { broadcast_replace_to group, :line_items }
  after_destroy_commit -> { broadcast_remove_to group, :line_items }
end
```

```erb
<%# Subscribe in the view %>
<%= turbo_stream_from @group, :line_items %>

<div id="line_items">
  <%= render @group.line_items %>
</div>
```

## Custom Stream Actions

Define custom actions for complex behaviors:

```javascript
// app/javascript/application.js
import { StreamActions } from "@hotwired/turbo"

StreamActions.highlight = function() {
  const element = document.querySelector(this.getAttribute('target'));
  element?.classList.add('highlight');
  setTimeout(() => element?.classList.remove('highlight'), 2000);
};

StreamActions.showDialog = function() {
  const target = this.getAttribute('target');
  document.querySelector(target)?.showModal();
};

// Sequential animations
StreamActions.animateCascade = async function() {
  const elements = document.querySelectorAll(this.getAttribute('targets'));
  for (const element of elements) {
    element.classList.add('animate');
    await new Promise(r => setTimeout(r, 250));
  }
};
```

```erb
<%# Usage in ERB %>
<%= turbo_stream.action "highlight", target: "#item_#{@item.id}" %>
<%= turbo_stream.action "showDialog", target: "#success-dialog" %>
```

## Inline Stream Tags (Client-Side)

Execute streams client-side:

```html
<template id="show-action-template">
  <turbo-stream action="showDialog" target="#dialog"></turbo-stream>
</template>

<script>
document.querySelector('#open-button').addEventListener('click', () => {
  const template = document.querySelector('#show-action-template');
  document.body.appendChild(template.content.cloneNode(true));
});
</script>
```

## Inter-Tab Communication

Sync state across browser tabs:

```javascript
// app/javascript/controllers/sync_controller.js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['status'];
  
  connect() {
    this.channel = new BroadcastChannel('app_sync');
    this.channel.onmessage = (event) => {
      if (event.data.type === 'refresh') {
        this.statusTarget.textContent = 'Updated in another tab';
      }
    };
  }

  notifyChange() {
    this.channel.postMessage({ type: 'refresh' });
  }
}
```

## List Animations with View Transitions

```erb
<%= turbo_stream.append "items", @item %>
<%= turbo_stream.action "animateCascade", targets: "#items > *:last-child" %>
```

```css
@view-transition {
  navigation: auto;
}

::view-transition-old(item) {
  animation: fade-out 0.3s ease;
}

::view-transition-new(item) {
  animation: fade-in 0.3s ease;
}
```

## Real-Time Combobox

```erb
<%= turbo_frame_tag "combobox_results", 
      src: search_items_path(q: params[:q]),
      data: { combobox_target: "results" } %>

<%= turbo_stream_from "search_results" %>
```

## Optimistic UI with Morph Reconciliation

```html
<form method="post" action="/favorites" data-optimistic-form>
  <template class="optimistic-template">
    <turbo-stream action="replace" target="favorite-btn">
      <template>
        <button id="favorite-btn" disabled>
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
    const template = e.target.querySelector('.optimistic-template');
    document.body.appendChild(template.content.cloneNode(true));
  });
});
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

## Key Points

- Prefer default actions before custom ones
- Use `refresh` for simple reconciliation (Turbo 8)
- Keep stream actions small and deterministic
- Broadcast from models for real-time features
- Use BroadcastChannel for cross-tab sync
