# DaisyUI Components

Pre-built components using DaisyUI classes.

## Buttons

```erb
<%# Primary action %>
<%= link_to "Save Budget", budget_path(@budget), class: "btn btn-primary" %>

<%# Secondary action %>
<%= link_to "Cancel", budgets_path, class: "btn btn-ghost" %>

<%# Destructive %>
<%= button_to "Delete", budget_path(@budget), method: :delete,
    class: "btn btn-error", 
    data: { turbo_confirm: "Are you sure?" } %>

<%# Sizes %>
<button class="btn btn-xs">Tiny</button>
<button class="btn btn-sm">Small</button>
<button class="btn btn-md">Medium</button>
<button class="btn btn-lg">Large</button>

<%# Loading state %>
<button class="btn btn-primary" disabled>
  <span class="loading loading-spinner loading-sm"></span>
  Saving...
</button>

<%# With icon %>
<button class="btn btn-primary gap-2">
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
  </svg>
  Save
</button>
```

## Cards

```erb
<%# Standard card %>
<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title"><%= @budget.name %></h2>
    <p><%= @budget.description %></p>
    <div class="card-actions justify-end">
      <%= link_to "View", budget_path(@budget), class: "btn btn-primary" %>
    </div>
  </div>
</div>

<%# Compact card %>
<div class="card card-compact bg-base-100 shadow-md">
  <div class="card-body">
    <h3 class="card-title text-sm"><%= @month.name %></h3>
    <p class="text-2xl font-bold"><%= number_to_currency(@month.total) %></p>
  </div>
</div>

<%# With image %>
<div class="card bg-base-100 shadow-xl">
  <figure><img src="/image.jpg" alt="Shoes" /></figure>
  <div class="card-body">
    <h2 class="card-title">Title</h2>
  </div>
</div>
```

## Forms

```erb
<%= form_with model: @budget, class: "space-y-4" do |f| %>
  
  <%# Text input %>
  <div class="form-control w-full">
    <%= f.label :name, class: "label" do %>
      <span class="label-text">Budget Name</span>
    <% end %>
    <%= f.text_field :name, 
        class: "input input-bordered w-full", 
        placeholder: "e.g., Monthly Budget" %>
    <% if @budget.errors[:name].any? %>
      <label class="label">
        <span class="label-text-alt text-error">
          <%= @budget.errors[:name].first %>
        </span>
      </label>
    <% end %>
  </div>

  <%# Select %>
  <div class="form-control w-full">
    <%= f.label :currency, class: "label" do %>
      <span class="label-text">Currency</span>
    <% end %>
    <%= f.select :currency, 
        [["ZAR", "ZAR"], ["USD", "USD"], ["EUR", "EUR"]],
        {}, class: "select select-bordered w-full" %>
  </div>

  <%# Checkbox %>
  <div class="form-control">
    <label class="label cursor-pointer justify-start gap-4">
      <%= f.check_box :shared, class: "checkbox checkbox-primary" %>
      <span class="label-text">Share with others</span>
    </label>
  </div>

  <%# Toggle %>
  <div class="form-control">
    <label class="label cursor-pointer justify-start gap-4">
      <%= f.check_box :notifications, class: "toggle toggle-primary" %>
      <span class="label-text">Enable notifications</span>
    </label>
  </div>

  <%# Radio buttons %>
  <div class="form-control">
    <label class="label cursor-pointer justify-start gap-4">
      <%= f.radio_button :period, "monthly", class: "radio radio-primary" %>
      <span class="label-text">Monthly</span>
    </label>
  </div>

  <%# Range slider %>
  <div class="form-control w-full">
    <%= f.label :percentage, class: "label" do %>
      <span class="label-text">Percentage</span>
    <% end %>
    <%= f.range_field :percentage, 
        class: "range range-primary", 
        min: 0, max: 100 %>
  </div>

  <div class="form-control mt-6">
    <%= f.submit "Save Budget", class: "btn btn-primary" %>
  </div>

<% end %>
```

## Modals

```erb
<%# DaisyUI modal with native <dialog> %>
<button class="btn" onclick="my_modal.showModal()">Open Modal</button>

<dialog id="my_modal" class="modal">
  <div class="modal-box">
    <h3 class="font-bold text-lg">Confirm Action</h3>
    <p class="py-4">Are you sure you want to proceed?</p>
    <div class="modal-action">
      <%= button_to "Confirm", delete_path, method: :delete, 
          class: "btn btn-error" %>
      <form method="dialog">
        <button class="btn">Cancel</button>
      </form>
    </div>
  </div>
</dialog>
```

## Navigation

```erb
<%# Navbar %>
<div class="navbar bg-base-100 shadow-lg">
  <div class="flex-1">
    <%= link_to "App", root_path, class: "btn btn-ghost text-xl" %>
  </div>
  <div class="flex-none gap-2">
    <div class="form-control">
      <input type="text" placeholder="Search" 
             class="input input-bordered w-24 md:w-auto" />
    </div>
    <div class="dropdown dropdown-end">
      <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar">
        <div class="w-10 rounded-full">
          <%= image_tag current_user.avatar_url %>
        </div>
      </div>
      <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box 
                              z-[1] w-52 p-2 shadow">
        <li><%= link_to "Settings", settings_path %></li>
        <li><%= button_to "Logout", logout_path, method: :delete %></li>
      </ul>
    </div>
  </div>
</div>

<%# Sidebar/Drawer %>
<div class="drawer lg:drawer-open">
  <input id="my-drawer" type="checkbox" class="drawer-toggle" />
  <div class="drawer-content">
    <!-- Page content -->
  </div>
  <div class="drawer-side">
    <label for="my-drawer" class="drawer-overlay"></label>
    <ul class="menu p-4 w-80 min-h-full bg-base-200">
      <li><%= link_to "Dashboard", dashboard_path %></li>
      <li><%= link_to "Budgets", budgets_path %></li>
    </ul>
  </div>
</div>

<%# Breadcrumbs %>
<div class="breadcrumbs text-sm">
  <ul>
    <li><%= link_to "Home", root_path %></li>
    <li><%= link_to "Budgets", budgets_path %></li>
    <li>Current Budget</li>
  </ul>
</div>

<%# Pagination %>
<div class="join">
  <%= link_to "1", items_path(page: 1), class: "join-item btn" %>
  <%= link_to "2", items_path(page: 2), class: "join-item btn btn-active" %>
  <%= link_to "3", items_path(page: 3), class: "join-item btn" %>
</div>
```

## Tables

```erb
<div class="overflow-x-auto">
  <table class="table">
    <thead>
      <tr>
        <th>Date</th>
        <th>Description</th>
        <th>Amount</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% @transactions.each do |transaction| %>
        <tr class="hover">
          <td><%= transaction.date.strftime("%d %b") %></td>
          <td><%= transaction.description %></td>
          <td class="font-mono <%= transaction.amount < 0 ? 'text-error' : 'text-success' %>">
            <%= number_to_currency(transaction.amount) %>
          </td>
          <td>
            <%= link_to "Edit", edit_transaction_path(transaction), 
                class: "btn btn-ghost btn-xs" %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
</div>
```

## Alerts & Feedback

```erb
<%# Flash messages %>
<% flash.each do |type, message| %>
  <% alert_class = { 
    notice: "alert-success", 
    alert: "alert-error", 
    warning: "alert-warning" 
  }[type.to_sym] || "alert-info" %>
  
  <div class="alert <%= alert_class %> shadow-lg mb-4">
    <span><%= message %></span>
  </div>
<% end %>

<%# Toast notifications %>
<div class="toast toast-end">
  <div class="alert alert-success">
    <span>Budget saved successfully.</span>
  </div>
</div>

<%# Badge %>
<span class="badge badge-primary">New</span>
<span class="badge badge-secondary badge-outline">Draft</span>
<span class="badge badge-error">Overdue</span>
```

## Stats

```erb
<div class="stats shadow">
  <div class="stat">
    <div class="stat-title">Total Income</div>
    <div class="stat-value text-success"><%= number_to_currency(@income) %></div>
    <div class="stat-desc">This month</div>
  </div>

  <div class="stat">
    <div class="stat-title">Total Expenses</div>
    <div class="stat-value text-error"><%= number_to_currency(@expenses) %></div>
    <div class="stat-desc">This month</div>
  </div>

  <div class="stat">
    <div class="stat-title">Balance</div>
    <div class="stat-value <%= @balance >= 0 ? 'text-success' : 'text-error' %>">
      <%= number_to_currency(@balance) %>
    </div>
  </div>
</div>
```

## Key Points

- DaisyUI components are semantic (`btn`, `card`, `alert`)
- Use `bg-base-100` for consistent backgrounds
- Component variants with modifiers (`btn-primary`, `alert-success`)
- Responsive sizing with `btn-sm`, `btn-lg`, etc.
