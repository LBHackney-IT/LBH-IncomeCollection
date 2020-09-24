class EvictionController < ApplicationController
  protect_from_forgery

  def new
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)
    @eviction_date = @tenancy.eviction_date
  end

  def create
    use_cases.create_eviction_date.execute(eviction_params: {
        tenancy_ref: tenancy_ref,
        eviction_date: eviction_params[:eviction_date]
    })

    flash[:notice] = 'Successfully created a new eviction date'
    redirect_to tenancy_path(id: tenancy_ref)
  rescue Exceptions::IncomeApiError => e
    flash[:notice] = "An error occurred: #{e.message}"
    redirect_to new_eviction_date_path(tenancy_ref: tenancy_ref)
  end

  private

  def eviction_params
    params.permit(
      :tenancy_ref, :eviction_date
    )
  end

  def tenancy_ref
    @tenancy_ref ||= eviction_params[:tenancy_ref]
  end
end
