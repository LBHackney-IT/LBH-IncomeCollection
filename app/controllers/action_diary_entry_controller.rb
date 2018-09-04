class ActionDiaryEntryController < ApplicationController
  def show
    @tenancy = tenancy_gateway.get_tenancy(tenancy_ref: params.fetch(:id))
  end

  def create
    use_case = Hackney::Income::CreateActionDiaryEntry.new
    use_case.execute(
      tenancy_ref: params.fetch(:tenancy_ref),
      balance: params.fetch(:balance),
      code: params.fetch(:code),
      type: params.fetch(:type),
      date: Date.today.strftime("%YYYY-%MM-%DD"),
      comment: params.fetch(:comment),
      universal_housing_username: params.fetch(:universal_housing_username)
    )

    flash[:notice] = 'Successfully created an action diary entry'
    redirect_to tenancy_path(id: params.fetch(:tenancy_ref))
  end

  private

  def tenancy_gateway
    Hackney::Income::LessDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      api_key: ENV['INCOME_COLLECTION_API_KEY'],
    )
  end
end
