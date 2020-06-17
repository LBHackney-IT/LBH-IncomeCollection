class AgreementsController < ApplicationController
  def new
    @tenancy_ref = params.fetch(:tenancy_ref)
  end
end
