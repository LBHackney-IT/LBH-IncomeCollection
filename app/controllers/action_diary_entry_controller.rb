class ActionDiaryEntryController < ApplicationController
  def show
    @tenancy = use_cases.tenancy_gateway.get_tenancy(tenancy_ref: params.fetch(:id))
    @code_options = use_cases.action_diary_entry_codes.code_dropdown_options
  end

  def index
    @id = params.fetch(:id)
    @actions = use_cases.view_actions.execute(tenancy_ref: @id)
  end

  def create
    use_cases.create_action_diary_entry.execute(
      tenancy_ref: params['tenancy_ref'],
      balance: params['balance'],
      code: params['code'],
      type: '',
      date: Date.today.strftime('%YYYY-%MM-%DD'),
      comment: params['comment'],
      universal_housing_username: params['universal_housing_username']
    )

    flash[:notice] = 'Successfully created an action diary entry'
    redirect_to tenancy_path(id: params.fetch(:tenancy_ref))
  end
end
