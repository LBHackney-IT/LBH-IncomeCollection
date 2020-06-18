class AgreementsController < ApplicationController
  def new
    @tenancy_ref = params.fetch(:tenancy_ref)
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: @tenancy_ref)
  end
end
