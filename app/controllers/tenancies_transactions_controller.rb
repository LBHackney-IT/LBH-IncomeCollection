class TenanciesTransactionsController < ApplicationController
  def index
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
    @court_case = court_case
  end

  private

  def court_case
    return unless FeatureFlag.active?('create_formal_agreements')

    @court_case ||= court_cases.last
  end

  def court_cases
    return unless FeatureFlag.active?('create_formal_agreements')

    @court_cases ||= use_cases.view_court_cases.execute(tenancy_ref: params.fetch(:id))
  end
end
