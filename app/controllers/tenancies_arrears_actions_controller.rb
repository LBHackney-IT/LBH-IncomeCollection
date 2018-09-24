class TenanciesArrearsActionsController < ApplicationController
  def index
    @id = params.fetch(:id)
    @actions = use_cases.view_actions.execute(tenancy_ref: @id)
  end
end
