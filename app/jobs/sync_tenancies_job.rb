class SyncTenanciesJob < ApplicationJob
  def perform
    self.class.set(wait_until: tomorrow_morning).perform_later

    tenancy_refs = sync_tenancies.execute
    Rails.logger.info("[SyncTenanciesJob] Synced #{tenancy_refs.count} tenancies from the Hackney Income API")
  end

  private

  def sync_tenancies
    Hackney::Income::SyncTenancies.new(
      tenancy_source_gateway: tenancy_source_gateway,
      tenancy_persistence_gateway: tenancy_persistence_gateway
    )
  end

  def tenancy_source_gateway
    Hackney::Income::ReallyDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      include_developer_data: Rails.application.config.include_developer_data?
    )
  end

  def tenancy_persistence_gateway
    Hackney::Income::SqlTenancyCaseGateway.new
  end

  def tomorrow_morning
    Date.tomorrow.to_time.advance(hours: 6)
  end
end
