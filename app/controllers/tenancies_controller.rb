require 'time'

class TenanciesController < ApplicationController
  include TenancyHelper

  def index
    response = use_cases.list_user_assigned_cases.execute(
      user_id: current_user_id,
      filter_params: Hackney::Income::FilterParams::ListUserAssignedCasesParams.new(list_user_assigned_cases_params)
    )

    @page_number = response.page_number
    @number_of_pages = response.number_of_pages
    @user_assigned_tenancies = valid_tenancies(response.tenancies)
    @showing_paused_tenancies = response.paused
    @page_params = request.query_parameters

    @tenancies = Kaminari.paginate_array(@user_assigned_tenancies).page(@page_number)
  end

  def show
    @previous_page_params = request.query_parameters[:page_params]
    @page_number = list_user_assigned_cases_params[:page]

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
      is_paused_until_date: Time.strptime(params.fetch(:is_paused_until), '%Y-%m-%d')
    )

    flash[:notice] = response.code.to_i == 204 ? 'Successfully paused' : "Unable to pause: #{response.message}"

    redirect_to tenancy_path(id: params.fetch(:id))
  end

  private

  # FIXME: stop filtering here, improve contact details
  def valid_tenancies(tenancies)
    tenancies.select { |t| t.primary_contact_name.present? }
  end

  def list_user_assigned_cases_params
    params.permit(:page, :recommended_actions, :paused, :full_patch, :upcoming_evictions, :upcoming_court_dates)
  end
end
