class TenanciesController < ApplicationController
  def index
    @user_assigned_tenancies = sorted_assigned_tenancies
  end

  def show
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  private

  def sorted_assigned_tenancies
    cases = use_cases.list_user_assigned_cases.execute(user_id: current_user_id)
    sort_orders = { red: 3, amber: 2, green: 1 }
    cases.sort_by { |c| [sort_orders[c.band.to_sym], c.score.to_i] }.reverse
  end

  def current_user_id
    current_user.fetch('id')
  end
end
