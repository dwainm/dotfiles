# Rails Code Style - Klop

## Style Rules

### Quotes
- **Double quotes only** (not single)
- Good: `"Budget created successfully"`
- Bad: `'Budget created successfully'`

### Whitespace
- **NO trailing whitespace**
- Run `bin/rubocop --autocorrect` to fix

### Method Definitions

**Endless methods for one-liners:**
```ruby
def full_name = "#{first_name} #{last_name}"
def total_amount = line_items.sum(:amount)
def archived? = archived_at.present?
```

**Multi-line with standard definition:**
```ruby
def calculate_total
  subtotal = line_items.sum(:amount)
  tax = subtotal * tax_rate
  subtotal + tax
end
```

### Model Ordering

Alphabetize within each section:

```ruby
class Budget < ApplicationRecord
  # 1. Associations (alphabetized)
  belongs_to :user
  has_many :budget_users, dependent: :destroy
  has_many :months, dependent: :destroy

  # 2. Validations (alphabetized)
  validates :currency, presence: true
  validates :name, presence: true

  # 3. Scopes (alphabetized)
  scope :active, -> { where(archived_at: nil) }
  scope :by_currency, ->(currency) { where(currency: currency) }
  scope :shared_with, ->(user) { joins(:budget_users).where(budget_users: { user_id: user.id }) }

  # 4. Callbacks (sparingly)
  before_validation :set_defaults

  # 5. Instance methods
  def full_name = "#{name} (#{currency})"

  private

  # Private methods at bottom
  def set_defaults
    self.currency ||= "ZAR"
  end
end
```

### Controller Structure

```ruby
class BudgetsController < ApplicationController
  # 1. Callbacks
  before_action :set_budget, only: [:show, :edit, :update, :destroy]

  # 2. Actions (alphabetized by action name)
  def create
    # ...
  end

  def destroy
    # ...
  end

  def index
    # ...
  end

  private

  # 3. Private methods at bottom
  def budget_params
    params.require(:budget).permit(:name, :currency, :description)
  end

  def set_budget
    @budget = current_user.budgets.find(params[:id])
  end
end
```

### Service Object Structure

```ruby
module Transactions
  class ImportService < ApplicationService
    # 1. Class method shortcut
    def self.call(...) = new(...).call

    # 2. Initialize with dependencies
    def initialize(budget:, file:)
      @budget = budget
      @file = file
    end

    # 3. Call method
    def call
      return failure("Invalid file format") unless valid_format?
      # ...
      success(result)
    end

    private

    # 4. Private methods at bottom
    attr_reader :budget, :file

    def valid_format?
      # ...
    end
  end
end
```

## RuboCop

Always run before committing:
```bash
bin/rubocop --autocorrect
```

If there are issues that can't be auto-corrected, fix them manually before committing.

## Response Format

When answering Rails questions, use this structure:

```markdown
## Answer

[Clear, direct answer]

## Code Example

[Working code demonstrating the solution]

## Why This Approach

[Explanation of the pattern and its benefits]

## Alternatives

[Other approaches and when to use them]
```
