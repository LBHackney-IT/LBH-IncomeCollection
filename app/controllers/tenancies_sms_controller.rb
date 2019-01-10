class TenanciesSmsController < ApplicationController
  def show
    @sms_templates = use_cases.list_sms_templates.execute(tenancy_ref: params.fetch(:id))
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  def create
    begin
      phone_numbers = params.fetch(:phone_numbers)
    rescue ActionController::ParameterMissing
      flash[:notice] = 'Failed to send message: Please select at least one phone number'
      return redirect_to create_tenancy_sms_path(id: params.fetch(:id))
    end

    use_cases.send_sms.execute(
      phone_numbers: phone_numbers,
      tenancy_ref: params.fetch(:id),
      template_id: params.fetch(:template_id),
      user_id: session[:current_user].fetch('id')
    )

    flash[:notice] = 'Successfully sent the tenant an SMS message'
    redirect_to tenancy_path(id: params.fetch(:id))
  end
end
