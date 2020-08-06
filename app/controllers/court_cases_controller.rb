class CourtCasesController < ApplicationController
  protect_from_forgery
  before_action { redirect_to worktray_path unless FeatureFlag.active?('create_formal_agreements') }

  def new
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @court_date = params['court_date']
    @court_outcome = params['court_outcome']
    @balance_on_court_outcome_date = params['balance_on_court_outcome_date']
    @strike_out_date = params['strike_out_date']
  end

  def create
    use_cases.create_court_case.execute(
      tenancy_ref: tenancy_ref,
      created_by: @current_user.name,
      **court_case_params
    )
    redirect_to show_success_court_case_path
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to new_court_case_path(tenancy_ref: tenancy_ref, **court_case_params)
  end

  def show_success
    flash[:notice] = 'Successfully created a new court case'
    redirect_to tenancy_path(id: tenancy_ref)
  end

  private

  def tenancy_ref
    @tenancy_ref ||= params.fetch(:tenancy_ref)
  end

  def court_case_params
    {
      court_date: params.fetch(:court_date),
      court_outcome: params.fetch(:court_outcome),
      balance_on_court_outcome_date: params.fetch(:balance_on_court_outcome_date),
      strike_out_date: params.fetch(:strike_out_date)
    }
  end
end
