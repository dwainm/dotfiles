# Rails Patterns for Klop

## Model Pattern

```ruby
# app/models/budget.rb
class Budget < ApplicationRecord
  # 1. Associations (alphabetized)
  belongs_to :user
  has_many :months, dependent: :destroy
  has_many :budget_users, dependent: :destroy

  # 2. Validations
  validates :name, presence: true
  validates :currency, presence: true

  # 3. Scopes (alphabetized)
  scope :active, -> { where(archived_at: nil) }
  scope :shared_with, ->(user) { joins(:budget_users).where(budget_users: { user_id: user.id }) }

  # 4. Callbacks (sparingly - prefer service objects)
  before_validation :set_defaults

  # 5. Instance methods
  def full_name = "#{name} (#{currency})"

  private

  def set_defaults
    self.currency ||= "ZAR"
  end
end
```

### Key Model Rules
1. Always use `.unscoped` when querying without `Current.user` context
2. Models have `default_scope` tied to `Current.user` - use `.unscoped` for service/background contexts
3. Keep callbacks minimal - prefer service objects for business logic
4. Alphabetize associations, scopes, validations

## Controller Pattern

```ruby
# app/controllers/budgets_controller.rb
class BudgetsController < ApplicationController
  before_action :set_budget, only: [:show, :edit, :update, :destroy]

  def index
    @budgets = current_user.budgets.active.order(:name)
  end

  def create
    @budget = current_user.budgets.build(budget_params)

    if @budget.save
      redirect_to @budget, notice: "Budget created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_budget
    @budget = current_user.budgets.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:name, :currency, :description)
  end
end
```

### Controller Rules
- Keep controllers thin - logic goes in services
- Use `Current.user` for scoping
- Return proper status codes (`:unprocessable_entity` for errors)
- Use strong parameters (never `.permit!`)

## Service Object Pattern

```ruby
# app/services/application_service.rb
class ApplicationService
  def self.call(...) = new(...).call

  Result = Data.define(:success, :data, :error) do
    def initialize(success:, data: nil, error: nil) = super
    def success? = success
    def failure? = !success
  end

  private

  def success(data) = Result.new(success: true, data: data)
  def failure(error) = Result.new(success: false, error: error)
end

# app/services/transactions/import_service.rb
module Transactions
  class ImportService < ApplicationService
    def initialize(budget:, file:)
      @budget = budget
      @file = file
    end

    def call
      return failure("Invalid file format") unless valid_format?

      transactions = parse_and_import
      success(transactions)
    end

    private

    attr_reader :budget, :file

    def valid_format?
      %w[.csv .ofx].include?(File.extname(file.original_filename).downcase)
    end

    def parse_and_import
      # Import logic here
    end
  end
end
```

### Service Rules
- Always inherit from `ApplicationService`
- Use `Result` pattern for return values
- Use `def self.call(...)` shortcut
- Keep private methods at bottom with `private` keyword

## Query Object Pattern

```ruby
# app/queries/application_query.rb
class ApplicationQuery
  def self.call(...) = new(...).call
  def initialize(relation) = @relation = relation
  private attr_reader :relation
end

# app/queries/transactions/search_query.rb
module Transactions
  class SearchQuery < ApplicationQuery
    def initialize(relation = BankTransaction.all, params: {})
      super(relation)
      @params = params
    end

    def call
      scope = relation
      scope = filter_by_term(scope)
      scope = filter_by_status(scope)
      apply_sorting(scope)
    end

    private

    attr_reader :params

    def filter_by_term(scope)
      return scope if params[:q].blank?
      scope.where("description LIKE :q OR reference LIKE :q", q: "%#{params[:q]}%")
    end

    def filter_by_status(scope)
      return scope if params[:status].blank?
      params[:status] == "categorized" ? scope.categorized : scope.uncategorized
    end

    def apply_sorting(scope)
      scope.order(params[:sort] == "recent" ? { date: :desc } : :date)
    end
  end
end
```

## Background Job Pattern

```ruby
# app/jobs/transaction_import_job.rb
class TransactionImportJob < ApplicationJob
  queue_as :default

  def perform(import_id)
    import = Import.find(import_id)
    import.update!(status: :processing)

    result = Transactions::ImportService.call(
      budget: import.budget,
      file: import.file
    )

    if result.success?
      import.update!(status: :completed, processed_count: result.data.count)
    else
      import.update!(status: :failed, error_message: result.error)
    end
  end
end
```

## Authentication Pattern (Current-based)

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user
  delegate :budget, to: :user, allow_nil: true
end

# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user, :signed_in?
  end

  private

  def require_authentication
    redirect_to login_path unless signed_in?
  end

  def signed_in? = Current.session.present?
  def current_user = Current.user
end
```

## Turbo Stream Response Pattern

```ruby
# app/controllers/line_items_controller.rb
def create
  @line_item = @group.line_items.build(line_item_params)

  respond_to do |format|
    if @line_item.save
      format.turbo_stream
      format.html { redirect_to @month }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

```erb
<%# app/views/line_items/create.turbo_stream.erb %>
<%= turbo_stream.prepend "line_items", @line_item %>
<%= turbo_stream.update "group_total", @group.total %>
```

## Database Query Debugging

### Rules
1. **Always use `.unscoped`** - Models have `default_scope` requiring `Current.user`
2. **Always check existence** before calling methods on results
3. **Output compact JSON** - easier to parse than `.inspect`

### Template
```ruby
bin/rails runner "
  result = MODEL.unscoped.where(CONDITIONS).limit(10)
  if result.any?
    result.each { |r| puts r.attributes.slice('id', 'KEY_FIELDS').to_json }
  else
    puts 'NOT_FOUND'
  end
"
```

### Examples
```ruby
# Find a budget
bin/rails runner "
  b = Budget.unscoped.find_by(id: 123)
  puts b ? b.attributes.slice('id', 'number', 'year', 'title').to_json : 'NOT_FOUND'
"

# Count line items
bin/rails runner "
  count = LineItem.unscoped.where(budget_id: 123).count
  puts({ budget_id: 123, line_item_count: count }.to_json)
"
```

## Error Handling Pattern

```ruby
# app/errors/application_error.rb
class ApplicationError < StandardError
  attr_reader :code, :details

  def initialize(message = nil, code: nil, details: {})
    @code = code
    @details = details
    super(message)
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ApplicationError, with: :handle_application_error

  private

  def not_found
    render "errors/not_found", status: :not_found
  end

  def handle_application_error(error)
    flash.now[:alert] = error.message
    render :new, status: :unprocessable_entity
  end
end
```

## Common Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [Rails API Documentation](https://api.rubyonrails.org/)
