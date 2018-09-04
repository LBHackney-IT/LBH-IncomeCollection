class ActionDiaryEntryController < ApplicationController
  def show
    @tenancy = tenancy_gateway.get_tenancy(tenancy_ref: params.fetch(:id))
    @type_options = type_options
    @code_options = code_options
  end

  def create
    use_case = Hackney::Income::CreateActionDiaryEntry.new(action_diary_gateway: action_diary_gateway)
    use_case.execute(
      tenancy_ref: params['tenancy_ref'],
      balance: params['balance'],
      code: params['code'],
      type: params['type'],
      date: Date.today.strftime("%YYYY-%MM-%DD"),
      comment: params['comment'],
      universal_housing_username: params['universal_housing_username']
    )

    flash[:notice] = 'Successfully created an action diary entry'
    redirect_to tenancy_path(id: params.fetch(:tenancy_ref))
  end

  private

  def action_diary_gateway
    Hackney::Income::ActionDiaryEntryGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      api_key: ENV['INCOME_COLLECTION_API_KEY'],
    )
  end

  def tenancy_gateway
    Hackney::Income::LessDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      api_key: ENV['INCOME_COLLECTION_API_KEY'],
    )
  end

  def type_options
    [
      ['General Note', 'GEN'],
      ['SYSTEM', 'SYS']
    ]
  end

  def code_options
    [
      ['GEN', 'GEN'],
      ['Z00', 'Z00']
    ]
  end
end
