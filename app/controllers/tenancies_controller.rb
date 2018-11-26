class TenanciesController < ApplicationController
  def index
    response = use_cases.list_user_assigned_cases.execute(
      user_id: current_user_id,
      page_number: page_number,
      count_per_page: cases_per_page,
      paused: paused?
    )

    @page_number = response.page_number
    @number_of_pages = response.number_of_pages
    @user_assigned_tenancies = valid_tenancies(response.tenancies)
    @showing_paused_tenancies = response.paused
  end

  def show
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  def pause
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
    @pause_reason_options = [
      ['Court date set', 'Court date set'],
      ['Eviction date set', 'Eviction date set'],
      ['Delayed benefit', 'Delayed benefit'],
      ['Promise of payment', 'Promise of payment'],
      ['Deceased', 'Deceased'],
      ['Other', 'Other']
    ]
  end

  def update
    response = use_cases.update_tenancy.execute(
      tenancy_ref: params.fetch(:id),
      is_paused_until: params.fetch(:is_paused_until)
    )

    flash[:notice] = response.code.to_i == 204 ? 'Successfully paused' : "Unable to pause: #{response.message}"

    redirect_to tenancy_path(id: params.fetch(:id))
  end

  private

  # FIXME: stop filtering here, improve contact details
  def valid_tenancies(tenancies)
    tenancies.select { |t| t.primary_contact_name.present? }
  end

  def current_user_id
    current_user.fetch('id')
  end

  def page_number
    params.fetch(:page, 1).to_i
  end

  def paused?
    ActiveModel::Type::Boolean.new.cast(params.fetch(:paused, false))
  end

  def cases_per_page
    20
  end
end
