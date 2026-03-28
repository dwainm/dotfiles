# Form Styling

Form patterns with Tailwind and DaisyUI.

## Rails Form Builder

### Basic Form

```erb
<%= form_with model: @budget, class: "space-y-6" do |f| %>
  <div>
    <%= f.label :name, class: "block text-sm font-medium text-gray-700 dark:text-gray-200" %>
    <%= f.text_field :name,
        class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm
               focus:border-blue-500 focus:ring-blue-500 sm:text-sm
               dark:border-gray-600 dark:bg-gray-700 dark:text-white",
        placeholder: "e.g., Monthly Budget" %>
  </div>

  <div class="flex items-center gap-4">
    <%= f.submit "Save",
        class: "inline-flex justify-center rounded-md bg-blue-600 px-4 py-2
               text-sm font-semibold text-white shadow-sm hover:bg-blue-700
               focus:outline-none focus:ring-2 focus:ring-blue-500
               focus:ring-offset-2 disabled:opacity-50" %>
    <%= link_to "Cancel", budgets_path,
        class: "text-sm font-semibold text-gray-700 hover:text-gray-900
               dark:text-gray-300 dark:hover:text-white" %>
  </div>
<% end %>
```

### With DaisyUI

```erb
<%= form_with model: @budget, class: "space-y-4" do |f| %>
  <div class="form-control w-full">
    <%= f.label :name, class: "label" do %>
      <span class="label-text">Budget Name</span>
    <% end %>
    <%= f.text_field :name, class: "input input-bordered w-full" %>
  </div>

  <div class="form-control w-full">
    <%= f.label :currency, class: "label" do %>
      <span class="label-text">Currency</span>
    <% end %>
    <%= f.select :currency, currencies, {}, class: "select select-bordered w-full" %>
  </div>

  <div class="form-control mt-6">
    <%= f.submit "Save Budget", class: "btn btn-primary" %>
  </div>
<% end %>
```

## Validation States

### Tailwind

```erb
<div>
  <%= f.label :email, class: "block text-sm font-medium text-gray-700" %>
  <%= f.email_field :email,
      class: "mt-1 block w-full rounded-md shadow-sm sm:text-sm
             #{@user.errors[:email].any? ? 
               'border-red-300 focus:border-red-500 focus:ring-red-500' : 
               'border-gray-300 focus:border-blue-500 focus:ring-blue-500'}" %>
  
  <% if @user.errors[:email].any? %>
    <p class="mt-1 text-sm text-red-600">
      <%= @user.errors[:email].first %>
    </p>
  <% end %>
</div>
```

### DaisyUI

```erb
<div class="form-control w-full">
  <%= f.label :email, class: "label" do %>
    <span class="label-text">Email</span>
  <% end %>
  <%= f.email_field :email,
      class: "input input-bordered w-full #{@user.errors[:email].any? ? 'input-error' : ''}" %>
  
  <% if @user.errors[:email].any? %>
    <label class="label">
      <span class="label-text-alt text-error">
        <%= @user.errors[:email].first %>
      </span>
    </label>
  <% end %>
</div>
```

## Inline Validation (Real-time)

```erb
<%= form_with model: @budget, 
    data: { controller: "validation" } do |f| %>
  <div>
    <%= f.text_field :name,
        data: { 
          validation_target: "input",
          action: "blur->validation#validateName"
        } %>
    <span data-validation-target="error" class="hidden text-red-600 text-sm"></span>
  </div>
<% end %>
```

```javascript
// app/javascript/controllers/validation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"]

  validateName() {
    const value = this.inputTarget.value
    
    if (value.length < 3) {
      this.showError("Name must be at least 3 characters")
    } else {
      this.clearError()
    }
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
    this.inputTarget.classList.add("border-red-500")
  }

  clearError() {
    this.errorTarget.classList.add("hidden")
    this.inputTarget.classList.remove("border-red-500")
  }
}
```

## Fieldsets and Groups

```erb
<fieldset class="border border-gray-200 rounded-md p-4 dark:border-gray-700">
  <legend class="text-sm font-medium text-gray-700 px-2 dark:text-gray-300">
    Budget Period
  </legend>
  
  <div class="grid grid-cols-2 gap-4">
    <div>
      <%= f.label :start_date, class: "block text-sm text-gray-600" %>
      <%= f.date_field :start_date, class: "input w-full" %>
    </div>
    <div>
      <%= f.label :end_date, class: "block text-sm text-gray-600" %>
      <%= f.date_field :end_date, class: "input w-full" %>
    </div>
  </div>
</fieldset>
```

## Checkboxes and Radios

### Tailwind

```erb
<%# Checkbox -->
<div class="flex items-center">
  <%= f.check_box :notifications,
      class: "h-4 w-4 rounded border-gray-300 text-blue-600
             focus:ring-blue-500" %>
  <%= f.label :notifications, class: "ml-2 block text-sm text-gray-900" %>
</div>

<%# Radio group -->
<div class="space-y-2">
  <%= f.collection_radio_buttons :category_id, Category.all, :id, :name do |b| %>
    <div class="flex items-center">
      <%= b.radio_button class: "h-4 w-4 border-gray-300 text-blue-600" %>
      <%= b.label class: "ml-2 block text-sm text-gray-900" %>
    </div>
  <% end %>
</div>
```

### DaisyUI

```erb
<%# Checkbox %>
<div class="form-control">
  <label class="label cursor-pointer justify-start gap-4">
    <%= f.check_box :notifications, class: "checkbox checkbox-primary" %>
    <span class="label-text">Enable notifications</span>
  </label>
</div>

<%# Toggle %>
<div class="form-control">
  <label class="label cursor-pointer justify-start gap-4">
    <%= f.check_box :active, class: "toggle toggle-primary" %>
    <span class="label-text">Active</span>
  </label>
</div>

<%# Radio %>
<div class="form-control">
  <label class="label cursor-pointer justify-start gap-4">
    <%= f.radio_button :period, "monthly", class: "radio radio-primary" %>
    <span class="label-text">Monthly</span>
  </label>
</div>
```

## Select with Stimulus Enhancement

```erb
<div data-controller="select">
  <%= f.select :category_id,
      options_from_collection_for_select(@categories, :id, :name),
      {},
      data: { select_target: "select", action: "change->select#changed" },
      class: "select w-full" %>
  
  <div data-select-target="preview" class="mt-2 text-sm text-gray-600">
    <!-- Dynamic preview -->
  </div>
</div>
```

## File Upload with Preview

```erb
<div data-controller="upload">
  <%= f.file_field :attachment,
      data: { upload_target: "input", action: "change->upload#preview" },
      class: "file-input file-input-bordered w-full",
      accept: ".csv,.ofx" %>
  
  <div data-upload-target="preview" class="hidden mt-4">
    <p class="text-sm text-gray-600">Selected: <span data-upload-target="filename"></span></p>
  </div>
</div>
```

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "filename"]

  preview() {
    const file = this.inputTarget.files[0]
    if (file) {
      this.filenameTarget.textContent = file.name
      this.previewTarget.classList.remove("hidden")
    }
  }
}
```

## Character Counter

```erb
<div data-controller="character-counter" data-character-counter-max-value="100">
  <%= f.text_area :description,
      data: { 
        character_counter_target: "input",
        action: "input->character-counter#update"
      },
      class: "textarea w-full",
      maxlength: 100 %>
  
  <p class="text-sm text-gray-500 mt-1">
    <span data-character-counter-target="count">0</span> / 100
  </p>
</div>
```

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const count = this.inputTarget.value.length
    this.countTarget.textContent = count
    
    if (count >= this.maxValue * 0.9) {
      this.countTarget.classList.add("text-red-500")
    } else {
      this.countTarget.classList.remove("text-red-500")
    }
  }
}
```

## Key Points

- Always show validation errors inline
- Use appropriate input types (email, tel, date, etc.)
- Add character counters for limited fields
- Use fieldsets to group related fields
- Ensure accessible labels for all inputs
- Style focus states clearly for keyboard navigation
