class AgreementsController < ApplicationController
  protect_from_forgery
  before_action { redirect_to worktray_path unless FeatureFlag.active?('create_informal_agreements') }

  def new
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @start_date = params['start_date'].nil? ? (Date.today + 1.day).to_s : params['start_date']
    @frequency = params['frequency']&.humanize
    @amount = params['amount']
    @notes = params['notes']
  end

  def create
    use_cases.create_agreement.execute(
      tenancy_ref: tenancy_ref,
      created_by: @current_user.name,
      **agreement_params
    )
    redirect_to show_success_path
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to new_agreement_path(tenancy_ref: tenancy_ref, **agreement_params)
  end

  def show_success
    flash[:notice] = 'Successfully created a new agreement'
    redirect_to tenancy_path(id: tenancy_ref)
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
    {
      frequency: params.fetch(:frequency).downcase,
      amount: params.fetch(:amount),
      start_date: params.fetch(:start_date),
      notes: params.fetch(:notes)
    }
  end
end
