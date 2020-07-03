class AgreementsController < ApplicationController
  protect_from_forgery
  before_action { redirect_to worktray_path unless FeatureFlag.active?('create_informal_agreements') }

  def new
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
  end

  def create
    use_cases.create_agreement.execute(
      tenancy_ref: tenancy_ref,
      frequency: params.fetch(:frequency).downcase,
      amount: params.fetch(:instalment_amount),
      start_date: params.fetch(:start_date),
      created_by: @current_user.name
    )

    flash[:notice] = 'Successfully created a new agreement'
    redirect_to tenancy_path(id: tenancy_ref)
  end

  def show
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @agreement = use_cases.view_agreements.execute(tenancy_ref: tenancy_ref)
                .find { |agreement| agreement.id == agreement_id }
  end

  private

  def tenancy_ref
    @tenancy_ref ||= params.fetch(:tenancy_ref)
  end

  def agreement_id
    @agreement_id ||= params.fetch(:id).to_i
  end
end
