module Hackney
  module Income
    class UseCaseFactory
      def list_user_assigned_cases
        Hackney::Income::ListUserAssignedCases.new(
          tenancy_gateway: income_tenancy_gateway
        )
      end

      def search_tenancies
        Hackney::Income::SearchTenanciesUsecase.new(
          search_gateway: search_tenancies_gateway
        )
      end

      def view_tenancy
        Hackney::Income::ViewTenancy.new(
          tenancy_gateway: tenancy_gateway,
          transactions_gateway: transactions_gateway,
          scheduler_gateway: scheduler_gateway,
          events_gateway: events_gateway
        )
      end

      def update_tenancy
        Hackney::Income::UpdateTenancy.new(
          tenancy_gateway: tenancy_gateway
        )
      end

      def view_actions
        Hackney::Income::ViewActions.new(
          actions_gateway: action_diary_gateway
        )
      end

      def send_sms
        Hackney::Income::SendSms.new(
          tenancy_gateway: tenancy_gateway,
          notification_gateway: notifications_gateway,
          events_gateway: events_gateway
        )
      end

      def send_email
        Hackney::Income::SendEmail.new(
          tenancy_gateway: tenancy_gateway,
          notification_gateway: notifications_gateway
        )
      end

      def list_sms_templates
        Hackney::Income::ListSmsTemplates.new(
          tenancy_gateway: tenancy_gateway,
          notifications_gateway: notifications_gateway
        )
      end

      def list_email_templates
        Hackney::Income::ListEmailTemplates.new(
          tenancy_gateway: tenancy_gateway,
          notifications_gateway: notifications_gateway
        )
      end

      def create_action_diary_entry
        Hackney::Income::CreateActionDiaryEntry.new(action_diary_gateway: action_diary_gateway)
      end

      def action_diary_entry_codes
        Hackney::Income::ActionDiaryEntryCodes
      end

      def find_or_create_user
        Hackney::Income::FindOrCreateUser.new(users_gateway: users_gateway)
      end

      # FIXME: gateways shouldn't be exposed by the UseCaseFactory, but ActionDiaryEntryController depends on it
      def tenancy_gateway
        Hackney::Income::LessDangerousTenancyGateway.new(
          api_host: ENV['INCOME_COLLECTION_API_HOST'],
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      private

      def users_gateway
        Hackney::Income::IncomeApiUsersGateway.new(
          api_host: ENV['INCOME_COLLECTION_LIST_API_HOST'],
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      def action_diary_gateway
        Hackney::Income::ActionDiaryEntryGateway.new(
          api_host: ENV['INCOME_COLLECTION_API_HOST'],
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      def transactions_gateway
        Hackney::Income::TransactionsGateway.new(
          api_host: ENV['INCOME_COLLECTION_API_HOST'],
          api_key: ENV['INCOME_COLLECTION_API_KEY'],
          include_developer_data: Rails.application.config.include_developer_data?
        )
      end

      def notifications_gateway
        Hackney::Income::GovNotifyGateway.new(
          sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'],
          api_key: ENV['GOV_NOTIFY_API_KEY']
        )
      end

      def scheduler_gateway
        Hackney::Income::SchedulerGateway.new
      end

      def events_gateway
        Hackney::Income::SqlEventsGateway.new
      end

      def search_tenancies_gateway
        Hackney::Income::SearchTenanciesGateway.new(
          api_host: ENV['INCOME_COLLECTION_API_HOST'],
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      # FIXME: Confusing
      def income_tenancy_gateway
        Hackney::Income::LessDangerousTenancyGateway.new(
          api_host: ENV['INCOME_COLLECTION_LIST_API_HOST'],
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end
    end
  end
end
