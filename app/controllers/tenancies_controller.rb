require 'time'

class TenanciesController < ApplicationController
  include TenancyHelper
  def index
    response = use_cases.list_user_assigned_cases.execute(
      user_id: current_user_id,
      page_number: page_number,
      count_per_page: cases_per_page,
      paused: paused?,
      full_patch: full_patch?,
      upcoming_court_dates: upcoming_court_dates?,
      upcoming_evictions: upcoming_evictions?
    )
    @page_number = response.page_number
    @number_of_pages = response.number_of_pages
    @user_assigned_tenancies = valid_tenancies(response.tenancies)
    @showing_paused_tenancies = response.paused
    @page_params = request.query_parameters

    @tenancies = Kaminari.paginate_array(@user_assigned_tenancies).page(@page_number)
  end

  def show
    query_params = request.query_parameters
    @previous_page_params = query_params[:page_params]

    @page_number = page_number

    tenancy_ref = params.fetch(:id)
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @actions = use_cases.view_actions.execute(tenancy_ref: tenancy_ref)
  end

  def pause
    @pause_tenancy = use_cases.pause_tenancy.execute(tenancy_ref: params.fetch(:id))
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
  rescue Exceptions::IncomeApiError::NotFoundError
    flash[:notice] = 'This tenancy is not eligible for pausing'
    redirect_to tenancy_path(id: params.fetch(:id))
  end

  def update
    response = use_cases.update_tenancy.execute(
      user_id: session[:current_user].fetch('id'),
      tenancy_ref: params.fetch(:id),
      pause_reason: pause_reasons.key(params.fetch(:action_code)),
      pause_comment: params.fetch(:pause_comment),
      action_code: params.fetch(:action_code),
      is_paused_until_date: parse_date(params.fetch(:is_paused_until))
    )

    flash[:notice] = response.code.to_i == 204 ? 'Successfully paused' : "Unable to pause: #{response.message}"

    redirect_to tenancy_path(id: params.fetch(:id))
  end

  private

  def parse_date(date_string)
    Time.strptime(date_string, '%Y-%m-%d')
  end

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

  def full_patch?
    ActiveModel::Type::Boolean.new.cast(params.fetch(:full_patch, false))
  end

  def upcoming_court_dates?
    ActiveModel::Type::Boolean.new.cast(params.fetch(:upcoming_court_dates, false))
  end

  def upcoming_evictions?
    ActiveModel::Type::Boolean.new.cast(params.fetch(:upcoming_evictions, false))
  end

  def cases_per_page
    20
  end
end
