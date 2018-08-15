class TenanciesController < ApplicationController
  def index
    list_tenancies = Hackney::Income::ListUserAssignedCases.new(tenancy_case_gateway: tenancy_case_gateway)
    @user_assigned_tenancies = list_tenancies.execute(assignee_id: current_user_id).sort_by! { |t| t.score.to_i }.reverse
  end

  def show
    @tenancy = view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  private

  def current_user_id
    current_user.fetch('id')
  end

  def view_tenancy
    Hackney::Income::ViewTenancy.new(
      tenancy_gateway: tenancy_gateway,
      transactions_gateway: transactions_gateway,
      scheduler_gateway: scheduler_gateway,
      events_gateway: events_gateway
    )
  end

  def tenancy_gateway
    Hackney::Income::LessDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      api_key: ENV['INCOME_COLLECTION_API_KEY'],
      # include_developer_data: Rails.application.config.include_developer_data?
    )
  end

  def transactions_gateway
    Hackney::Income::TransactionsGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      api_key: ENV['INCOME_COLLECTION_API_KEY'],
      include_developer_data: Rails.application.config.include_developer_data?
    )
  end

  def scheduler_gateway
    Hackney::Income::SchedulerGateway.new
  end

  def events_gateway
    Hackney::Income::SqlEventsGateway.new
  end

  def tenancy_case_gateway
    Hackney::Income::SqlTenancyCaseGateway.new
  end
end
