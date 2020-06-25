class AgreementsController < ApplicationController
  before_action { redirect_to worktray_path unless FeatureFlag.active?('create_informal_agreements') }

  def new
    @tenancy_ref = params.fetch(:tenancy_ref)
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: @tenancy_ref)
  end

  def create
    tenancy_ref = params.fetch(:tenancy_ref)
    use_cases.create_agreement.execute(
      tenancy_ref: tenancy_ref,
      frequency: params.fetch(:frequency).downcase,
      amount: params.fetch(:instalment_amount),
      start_date: params.fetch(:start_date)
    )

    flash[:notice] = 'Successfully created a new agreement'
    redirect_to tenancy_path(id: tenancy_ref)
  end

  def show
    @tenancy_ref = params.fetch(:tenancy_ref)
  end
end
