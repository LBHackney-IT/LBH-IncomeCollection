class CourtCasesController < ApplicationController
  protect_from_forgery
  before_action { redirect_to worktray_path unless FeatureFlag.active?('create_formal_agreements') }

  def new
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
  end

  def create
    create_court_case_params = {
      tenancy_ref: tenancy_ref,
      court_date: params.fetch(:court_date)
    }

    use_cases.create_court_case.execute(create_court_case_params: create_court_case_params)

    redirect_to show_success_court_case_path(message: 'Successfully created a new court case')
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to new_court_case_path(tenancy_ref: tenancy_ref, **create_court_case_params)
  end

  def edit_court_date
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @court_date = court_case.court_date.to_date.strftime('%F')
  end

  def update_court_date
    update_court_case_params = {
      id: court_case_id,
      court_date: params.fetch(:court_date)
    }

    use_cases.update_court_case.execute(court_case_params: update_court_case_params)

    redirect_to show_success_court_case_path(message: 'Successfully updated the court case')
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to edit_court_date_path(tenancy_ref: tenancy_ref, **update_court_case_params)
  end

  def edit_court_outcome
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @court_outcome = court_case.court_outcome
    @balance_on_court_outcome_date = court_case.balance_on_court_outcome_date
    @strike_out_date = court_case.strike_out_date&.to_date&.strftime('%F')
  end

  def update_court_outcome
    update_court_outcome_params = {
      id: court_case_id,
      court_outcome: params.dig(:court_outcome),
      balance_on_court_outcome_date: params.dig(:balance_on_court_outcome_date),
      strike_out_date: params.dig(:strike_out_date)
    }

    use_cases.update_court_case.execute(court_case_params: update_court_outcome_params)

    flash[:notice] = 'Successfully updated the court case'
    redirect_to show_court_case_path(tenancy_ref: tenancy_ref, court_case_id: court_case_id)
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to update_court_outcome_path(tenancy_ref: tenancy_ref, **update_court_outcome_params)
  end

  def show
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @court_case = court_case
    @adjourned = court_case.court_outcome&.start_with?('Adjourned')
  end

  def show_success
    flash[:notice] = params.fetch(:message)
    redirect_to tenancy_path(id: tenancy_ref)
  end

  private

  def tenancy_ref
    @tenancy_ref ||= params.fetch(:tenancy_ref)
  end

  def court_case_id
    @court_case_id ||= params.fetch(:court_case_id)
  end

  def court_case
    @court_case ||= use_cases.view_court_cases.execute(tenancy_ref: tenancy_ref)
                            .detect { |c| c.id == court_case_id.to_i }
  end
end
