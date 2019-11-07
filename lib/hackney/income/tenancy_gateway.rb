require 'net/http'
require 'uri'

# This gateway handles access to tenancy data in Universal Housing, but due to the divergence of where some data
# is persisted, some of these methods call the Income API, and some call the Tenancy API, and the gateway needs
# to be initialised with the relevant host. The key is the same for both.
module Hackney
  module Income
    class TenancyGateway
      GetTenanciesResponse = Struct.new(:tenancies, :number_of_pages)

      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      # Income API
      def get_tenancies(filter_params:)
        uri = URI("#{@api_host}/v1/cases")

        payload = filter_params.to_params
        uri.query = URI.encode_www_form(payload)

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        raise Exceptions::IncomeApiError.new(res), "when trying to get_tenancies for Params '#{filter_params.to_params.inspect}'" unless res.is_a? Net::HTTPSuccess

        body = JSON.parse(res.body)

        number_of_pages = body.fetch('number_of_pages')
        tenancies = body.fetch('cases').map do |tenancy|
          t = Hackney::Income::Domain::TenancyListItem.new
          t.ref = tenancy['ref']
          t.current_balance = tenancy['current_balance']['value']
          t.current_arrears_agreement_status = tenancy['current_arrears_agreement_status']
          t.latest_action_code = tenancy['latest_action']['code']
          t.latest_action_date = tenancy['latest_action']['date']
          t.primary_contact_name = tenancy['primary_contact']['name']
          t.primary_contact_short_address = tenancy['primary_contact']['short_address']
          t.primary_contact_postcode = tenancy['primary_contact']['postcode']
          t.score = tenancy['priority_score']
          t.band = tenancy['priority_band']

          t.balance_contribution = tenancy['balance_contribution']
          t.days_in_arrears_contribution = tenancy['days_in_arrears_contribution']
          t.days_since_last_payment_contribution = tenancy['days_since_last_payment_contribution']
          t.payment_amount_delta_contribution = tenancy['payment_amount_delta_contribution']
          t.payment_date_delta_contribution = tenancy['payment_date_delta_contribution']
          t.number_of_broken_agreements_contribution = tenancy['number_of_broken_agreements_contribution']
          t.active_agreement_contribution = tenancy['active_agreement_contribution']
          t.broken_court_order_contribution = tenancy['broken_court_order_contribution']
          t.nosp_served_contribution = tenancy['nosp_served_contribution']
          t.active_nosp_contribution = tenancy['active_nosp_contribution']

          t.days_in_arrears = tenancy['days_in_arrears']
          t.days_since_last_payment = tenancy['days_since_last_payment']
          t.payment_amount_delta = tenancy['payment_amount_delta']
          t.payment_date_delta = tenancy['payment_date_delta']
          t.number_of_broken_agreements = tenancy['number_of_broken_agreements']
          t.broken_court_order = tenancy['broken_court_order']
          t.nosp_served = tenancy['nosp_served']
          t.active_nosp = tenancy['active_nosp']

          t.patch_code = tenancy['patch_code']
          t.classification = tenancy['classification']

          if Rails.env.staging?
            Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: t)
          else
            t
          end
        end

        GetTenanciesResponse.new(tenancies, number_of_pages)
      end

      # Tenancy API
      def get_tenancy(tenancy_ref:)
        uri = URI("#{@api_host}/v1/tenancies/#{ERB::Util.url_encode(tenancy_ref)}")

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        raise Exceptions::TenancyApiError.new(res), "when trying to tenancy using ref '#{tenancy_ref}'" unless res.is_a? Net::HTTPSuccess

        tenancy = JSON.parse(res.body)
        tenancy_item = Hackney::Income::Domain::Tenancy.new.tap do |t|
          t.ref = tenancy.dig('tenancy_details', 'ref')
          t.tenure = tenancy.dig('tenancy_details', 'tenure')
          t.rent = tenancy.dig('tenancy_details', 'rent').gsub(/[^\d\.-]/, '').to_f
          t.service = tenancy.dig('tenancy_details', 'service').gsub(/[^\d\.-]/, '').to_f
          t.other_charge = tenancy.dig('tenancy_details', 'other_charge').gsub(/[^\d\.-]/, '').to_f
          t.current_arrears_agreement_status = tenancy.dig('tenancy_details', 'current_arrears_agreement_status')
          t.current_balance = tenancy.dig('tenancy_details', 'current_balance')['value']
          t.primary_contact_name = tenancy.dig('tenancy_details', 'primary_contact_name')
          t.primary_contact_long_address = tenancy.dig('tenancy_details', 'primary_contact_long_address')
          t.primary_contact_postcode = tenancy.dig('tenancy_details', 'primary_contact_postcode')
          t.payment_ref = tenancy.dig('tenancy_details', 'payment_ref')
          t.num_bedrooms = tenancy.dig('tenancy_details', 'num_bedrooms')
          t.arrears_actions = extract_action_diary(events: tenancy.dig('latest_action_diary_events'))
          t.agreements = extract_agreements(agreements: tenancy.dig('latest_arrears_agreements'))
          t.start_date = tenancy.dig('tenancy_details', 'start_date')
        end

        return Hackney::Income::Anonymizer.anonymize_tenancy(tenancy: tenancy_item) if Rails.env.staging?

        tenancy_item
      end

      # Income API
      def update_tenancy(username:, tenancy_ref:, is_paused_until_date:, pause_reason:, pause_comment:, action_code:)
        uri = URI.parse(File.join(@api_host, "/v1/tenancies/#{ERB::Util.url_encode(tenancy_ref)}"))
        req = Net::HTTP::Patch.new(uri)
        req['X-Api-Key'] = @api_key
        req.set_form_data(
          is_paused_until: is_paused_until_date.iso8601,
          username: username,
          pause_reason: pause_reason,
          pause_comment: pause_comment,
          action_code: action_code
        )

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
        res
      end

      def get_case_priority(tenancy_ref:)
        uri = URI.parse(File.join(@api_host, "/v1/tenancies/#{ERB::Util.url_encode(tenancy_ref)}"))
        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        return {} if res.is_a? Net::HTTPNotFound
        raise Exceptions::IncomeApiError.new(res), "when trying to get_case_priority using '#{uri}'" if res.is_a? Net::HTTPInternalServerError

        JSON.parse(res.body).deep_symbolize_keys
      end

      def get_tenancy_pause(tenancy_ref:)
        uri = URI.parse(File.join(@api_host, "/v1/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/pause"))
        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to get_tenancy_pause with tenancy_ref: '#{tenancy_ref}'" if res.is_a? Net::HTTPNotFound
        raise Exceptions::IncomeApiError.new(res), "when trying to get_tenancy_pause using '#{uri}'" if res.is_a? Net::HTTPInternalServerError

        tenancy = JSON.parse(res.body)

        {
          is_paused_until: tenancy['is_paused_until'],
          pause_reason: tenancy['pause_reason'],
          pause_comment: tenancy['pause_comment']
        }
      end

      # Tenancy API
      def get_contacts_for(tenancy_ref:)
        uri = URI("#{@api_host}/v1/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/contacts")

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        contacts = JSON.parse(res.body)['data']['contacts']

        return [] if contacts.blank?

        contacts = contacts.map do |c|
          Hackney::Income::Domain::Contact.new.tap do |t|
            t.contact_id = c['contact_id']
            t.email_address = c['email_address']
            t.uprn = c['uprn']
            t.address_line_1 = c['address_line1']
            t.address_line_2 = c['address_line2']
            t.address_line_3 = c['address_line3']
            t.first_name = c['first_name']
            t.last_name = c['last_name']
            t.full_name = c['full_name']
            t.larn = c['larn']
            t.telephone_1 = c['telephone1']
            t.telephone_2 = c['telephone2']
            t.telephone_3 = c['telephone3']
            t.cautionary_alert = c['cautionary_alert']
            t.property_cautionary_alert = c['property_cautionary_alert']
            t.house_ref = c['house_ref']
            t.title = c['title']
            t.full_address_display = c['full_address_display']
            t.full_address_search = c['full_address_search']
            t.post_code = c['post_code']
            t.date_of_birth = c['date_of_birth']
            t.hackney_homes_id = c['hackney_homes_id']
            t.responsible = c['responsible']
          end
        end

        return Hackney::Income::Anonymizer.anonymize_contacts(contacts: contacts) if Rails.env.staging?

        contacts
      end

      private

      def extract_action_diary(events:)
        events.map do |e|
          Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
            t.balance = e['balance'].gsub(/[^\d\.-]/, '').to_f
            t.code = e['code']
            t.type = e['type']
            t.date = e['date']
            t.comment = e['comment']
            t.universal_housing_username = e['universal_housing_username']
          end
        end
      end

      def extract_agreements(agreements:)
        agreements.map do |a|
          Hackney::Income::Domain::ArrearsAgreement.new.tap do |t|
            t.amount = a['amount'].gsub(/[^\d\.-]/, '').to_f
            t.breached = a['breached']
            t.clear_by = a['clear_by']
            t.frequency = a['frequency']
            t.start_balance = a['start_balance']
            t.start_date = a['start_date']
            t.status = a['status']
          end
        end
      end
    end
  end
end
