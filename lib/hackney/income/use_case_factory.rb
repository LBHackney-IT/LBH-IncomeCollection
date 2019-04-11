module Hackney
  module Income
    class UseCaseFactory
      def list_user_assigned_cases
        Hackney::Income::ListUserAssignedCases.new(
          tenancy_gateway: income_api_tenancy_gateway
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
          transactions_gateway: transactions_gateway
        )
      end

      def pause_tenancy
        Hackney::Income::PauseTenancy.new(
          tenancy_gateway: income_api_tenancy_gateway
        )
      end

      def update_tenancy
        Hackney::Income::UpdateTenancy.new(
          tenancy_gateway: income_api_tenancy_gateway
        )
      end

      def view_actions
        Hackney::Income::ViewActions.new(
          get_diary_entries_gateway: get_diary_entries_gateway
        )
      end

      def send_sms
        Hackney::Income::SendSms.new(
          tenancy_gateway: tenancy_gateway,
          notification_gateway: notifications_gateway
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

      def get_letter_preview
        Hackney::Income::GetLetterPreview.new(
          letters_gateway: letters_gateway
        )
      end

      def send_letter
        Hackney::Income::SendLetter.new(
          letters_gateway: letters_gateway
        )
      end

      def get_all_documents
        Hackney::Income::GetAllDocuments.new(
          documents_gateway: documents_gateway
        )
      end

      def download_document
        Hackney::Income::DownloadDocument.new(
          documents_gateway: documents_gateway
        )
      end

      def list_letter_templates
        Hackney::Income::ListLetterTemplates.new(
          letters_gateway: letters_gateway
        )
      end

      def create_action_diary_entry
        Hackney::Income::CreateActionDiaryEntry.new(create_action_diary_gateway: create_action_diary_gateway)
      end

      def action_diary_entry_codes
        Hackney::Income::ActionDiaryEntryCodes
      end

      def find_or_create_user
        Hackney::Income::FindOrCreateUser.new(users_gateway: users_gateway)
      end

      # FIXME: gateways shouldn't be exposed by the UseCaseFactory, but ActionDiaryEntryController depends on it
      TENANCY_API = ENV.fetch('INCOME_COLLECTION_API_HOST')

      def tenancy_gateway
        Hackney::Income::TenancyGateway.new(
          api_host: TENANCY_API,
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      private

      INCOME_API_HOST = ENV['INCOME_COLLECTION_LIST_API_HOST']

      def users_gateway
        Hackney::Income::IncomeApiUsersGateway.new(
          api_host: INCOME_API_HOST,
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      def create_action_diary_gateway
        Hackney::Income::CreateActionDiaryEntryGateway.new(
          api_host: INCOME_API_HOST,
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      def get_diary_entries_gateway
        Hackney::Income::GetActionDiaryEntriesGateway.new(
          api_host: TENANCY_API,
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      def transactions_gateway
        Hackney::Income::TransactionsGateway.new(
          api_host: TENANCY_API,
          api_key: ENV['INCOME_COLLECTION_API_KEY'],
          include_developer_data: Rails.application.config.include_developer_data?
        )
      end

      def notifications_gateway
        Hackney::Income::GovNotifyGateway.new(
          sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'],
          api_host: INCOME_API_HOST,
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      def letters_gateway
        Hackney::Income::LettersGateway.new(
          api_host: INCOME_API_HOST,
          api_key: ENV.fetch('INCOME_COLLECTION_API_KEY')
        )
      end

      def documents_gateway
        Hackney::Income::DocumentsGateway.new(
          api_host: INCOME_API_HOST,
          api_key: ENV.fetch('INCOME_COLLECTION_API_KEY')
        )
      end

      def search_tenancies_gateway
        Hackney::Income::SearchTenanciesGateway.new(
          api_host: TENANCY_API,
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end

      def income_api_tenancy_gateway
        Hackney::Income::TenancyGateway.new(
          api_host: INCOME_API_HOST,
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end
    end
  end
end
