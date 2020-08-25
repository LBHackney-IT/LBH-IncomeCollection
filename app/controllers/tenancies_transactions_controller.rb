class TenanciesTransactionsController < ApplicationController
  def index
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
    @court_case = court_case
  end
end
