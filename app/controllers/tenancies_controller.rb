require 'time'

class TenanciesController < ApplicationController
  include TenancyHelper

  before_action :set_patch_code_cookie, only: :index

  def index
    response = use_cases.list_cases.execute(
      filter_params: Hackney::Income::FilterParams::ListCasesParams.new(list_cases_params)
    )

    @page_number = response.page_number
    @number_of_pages = response.number_of_pages
    @tenancies = valid_tenancies(response.tenancies)
    @showing_paused_tenancies = response.paused
    @page_params = request.query_parameters

    @tenancies = Kaminari.paginate_array(@tenancies).page(@page_number)
  end

  def show
    @previous_page_params = request.query_parameters[:page_params]
    @page_number = list_cases_params[:page]

    tenancy_ref = params.fetch(:id)
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
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
      user_id: current_user_id,
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

  def list_cases_params
    permitted_params = params.permit(:page, :recommended_actions, :paused, :full_patch, :upcoming_evictions, :upcoming_court_dates, :patch_code)

    permitted_params[:patch_code] ||= cookies[:patch_code] if cookies[:patch_code].present?

    permitted_params
  end

  def set_patch_code_cookie
    patch_code_param = params.permit(:patch_code)
    return if patch_code_param.blank?

    cookies[:patch_code] = patch_code_param[:patch_code]
  end
end
