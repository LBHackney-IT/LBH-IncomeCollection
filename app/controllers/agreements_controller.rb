class AgreementsController < ApplicationController
  protect_from_forgery

  def payment_type
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @court_cases = use_cases.view_court_cases.execute(tenancy_ref: tenancy_ref)
  end

  def set_payment_type
    payment_type = params.dig(:payment_type)

    if payment_type
      redirect_to new_agreement_path(tenancy_ref: tenancy_ref, payment_type: payment_type)
    else
      redirect_to agreement_payment_type_path(tenancy_ref: tenancy_ref)
    end
  end

  def new
    @payment_type = params.dig(:payment_type)

    redirect_to agreement_payment_type_path(tenancy_ref: tenancy_ref) if @payment_type.nil?

    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)

    @court_cases = use_cases.view_court_cases.execute(tenancy_ref: tenancy_ref)

    @agreement = Hackney::Income::Domain::Agreement.new(agreement_params)
  end

  def create
    @agreement = Hackney::Income::Domain::Agreement.new(agreement_params)

    return redirect_to new_agreement_path(agreement_params) if @agreement.invalid?

    agreement = use_cases.create_agreement.execute(
      created_by: @current_user.name,
      tenancy_ref: agreement_params[:tenancy_ref],
      agreement_type: agreement_params[:agreement_type],
      amount: agreement_params[:amount],
      frequency: agreement_params[:frequency],
      start_date: agreement_params[:start_date],
      notes: agreement_params[:notes],
      court_case_id: agreement_params[:court_case_id],
      initial_payment_amount: agreement_params[:lump_sum_amount],
      initial_payment_date: agreement_params[:lump_sum_date]
    )
    redirect_to show_agreement_path(tenancy_ref: tenancy_ref, id: agreement.id) if agreement
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to new_agreement_path(tenancy_ref: tenancy_ref, **agreement_params)
  end

  def show
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @agreement = use_cases.view_agreements.execute(tenancy_ref: tenancy_ref)
                .find { |agreement| agreement.id == agreement_id }
  end

  def confirm_cancellation
    tenancy_ref
    agreement_id
  end

  def cancel
    use_cases.cancel_agreement.execute(agreement_id: agreement_id)

    flash[:notice] = 'Successfully cancelled the agreement'
    redirect_to tenancy_path(id: tenancy_ref)
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred while cancelling the agreement: #{e.message}"
    render :confirm_cancellation, tenancy_ref: tenancy_ref, id: agreement_id
  end

  def show_history
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @agreements = use_cases.view_agreements.execute(tenancy_ref: tenancy_ref)
  end

  private

  def tenancy_ref
    @tenancy_ref ||= params.fetch(:tenancy_ref)
  end

  def agreement_id
    @agreement_id ||= params.fetch(:id).to_i
  end

  def agreement_params
    params.permit(
      :tenancy_ref,
      :agreement_type,
      :starting_balance,
      :amount,
      :frequency,
      :start_date,
      :notes,
      :court_case_id,
      :payment_type,
      :lump_sum_amount,
      :lump_sum_date
    )
  end
end
