class TenanciesController < ApplicationController
  def index
    response = use_cases.list_user_assigned_cases.execute(
      user_id: current_user_id,
      page_number: page_number,
      count_per_page: cases_per_page
    )

    @page_number = response.page_number
    @number_of_pages = response.number_of_pages
    @user_assigned_tenancies = sorted_tenancies(response.tenancies)
  end

  def show
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  private

  def sorted_tenancies(tenancies)
    sort_orders = { red: 3, amber: 2, green: 1 }
    tenancies.sort_by { |c| [sort_orders[c.band.to_sym], c.score.to_i] }.reverse
  end

  def current_user_id
    current_user.fetch('id')
  end

  def page_number
    params.fetch(:page, 1).to_i
  end

  def cases_per_page
    20
  end
end
