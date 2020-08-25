class TenanciesEmailController < ApplicationController
  def show
    @email_templates = use_cases.list_email_templates.execute(tenancy_ref: params.fetch(:id))
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
    @court_case = court_case
  end

  def create
    begin
      email_addresses = params.fetch(:email_addresses)
    rescue ActionController::ParameterMissing
      flash[:notice] = 'Failed to send email: Please select at least one email address'
      return redirect_to create_tenancy_email_path(id: params.fetch(:id))
    end

    use_cases.send_email.execute(
      tenancy_ref: params.fetch(:id),
      email_addresses: email_addresses,
      template_id: params.fetch(:template_id),
      username: current_user.name
    )

    flash[:notice] = 'Successfully sent the tenant an Email'
    redirect_to tenancy_path(id: params.fetch(:id))
  end
end
