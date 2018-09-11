class TenanciesEmailController < ApplicationController
  def show
    @email_templates = use_cases.list_email_templates.execute(tenancy_ref: params.fetch(:id))
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  def create
    use_cases.send_email.execute(
      tenancy_ref: params.fetch(:id),
      template_id: params.fetch(:template_id)
    )

    flash[:notice] = 'Successfully sent the tenant an Email'
    redirect_to tenancy_path(id: params.fetch(:id))
  end
end
