class ActionDiaryEntryController < ApplicationController
  def show
    @tenancy = use_cases.tenancy_gateway.get_tenancy(tenancy_ref: params.fetch(:tenancy_ref))
    @code_options = use_cases.action_diary_entry_codes.code_dropdown_options
  end

  def index
    @id = params.fetch(:tenancy_ref)
    @actions = use_cases.view_actions.execute(tenancy_ref: @id)
  end

  def create
    unless use_cases.action_diary_entry_codes.valid_code?(params.fetch(:code), user_accessible: true)
      head(:bad_request)
      return
    end

    use_cases.create_action_diary_entry.execute(
      tenancy_ref: params.fetch(:tenancy_ref),
      action_code: params.fetch(:code),
      comment: params.fetch(:comment),
      username: current_user.name
    )

    flash[:notice] = 'Successfully created an action diary entry'
    redirect_to worktray_path
  end
end
