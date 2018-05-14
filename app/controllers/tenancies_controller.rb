class TenanciesController < ApplicationController
  def index
    tenancy_gateway = Hackney::Income::StubTenancyGateway.new
    list_tenancies = Hackney::Income::ListTenanciesInArrears.new(tenancy_gateway: tenancy_gateway)
    @tenancies_in_arrears = list_tenancies.execute
  end

  def show
    tenancy_gateway = Hackney::Income::StubTenancyGateway.new
    view_tenancy = Hackney::Income::ViewTenancy.new(tenancy_gateway: tenancy_gateway)
    @tenancy = view_tenancy.execute(tenancy_ref: params[:id])
  end
end
