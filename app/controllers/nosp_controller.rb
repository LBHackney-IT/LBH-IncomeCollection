class NospController < ApplicationController
  protect_from_forgery

  def new
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @nosp_served_date = @tenancy.nosp.served_date
  end

  def create
    use_cases.create_nosp_dates.execute(
      nosp_params: {
          tenancy_ref: tenancy_ref,
          nosp_served_date: nosp_params[:nosp_served_date]
      },
      username: current_user.name
    )

    flash[:notice] = 'Successfully added NoSP date'
    redirect_to tenancy_path(id: tenancy_ref)
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to new_nosp_dates_path(tenancy_ref: tenancy_ref)
  end

  private

  def nosp_params
    params.permit(
      :tenancy_ref, :nosp_served_date
    )
  end

  def tenancy_ref
    @tenancy_ref ||= nosp_params[:tenancy_ref]
  end
end
