require 'time'

class TenanciesController < ApplicationController
  include WorktrayHelper
  include TenancyHelper

  before_action :set_filter_cookie, only: :index

  def index
    @filter_params = Hackney::Income::FilterParams::ListCasesParams.new(list_filter_params)
    response = use_cases.list_cases.execute(filter_params: @filter_params)

    @page_number = response.page_number
    @number_of_pages = response.number_of_pages
    @tenancies = valid_tenancies(response.tenancies)
    @showing_paused_tenancies = response.paused
    @page_params = request.query_parameters

    @tenancies = Kaminari.paginate_array(
      @tenancies, total_count: @filter_params.count_per_page * @number_of_pages
    ).page(@page_number).per(@filter_params.count_per_page)

    respond_to do |format|
      format.html {}
      format.json do
        render json: {
            tenancies: @tenancies,
            page: @page_number,
            number_of_pages: @number_of_pages
        }.to_json
      end
    end
  rescue Exceptions::IncomeApiError => e
    Raven.capture_exception(e)
    flash[:notice] = 'An error occurred while loading your worktray, this may be caused by an Universal Housing outage'
  end

  def show
    @previous_page_params = request.query_parameters[:page_params]
    @page_number = list_filter_params[:page]

    tenancy_ref = params.fetch(:id)
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)

    if FeatureFlag.active?('create_informal_agreements')
      @agreements = use_cases.view_agreements.execute(tenancy_ref: tenancy_ref)
      @agreement = @agreements.find { |agreement| %w[live breached].include?(agreement.current_state) }
    end

    render :show
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
      username: current_user.name,
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
end
