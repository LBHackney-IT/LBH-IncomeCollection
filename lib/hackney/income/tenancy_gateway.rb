require 'net/http'
require 'uri'

module Hackney
  module Income
    class TenancyGateway
      GetTenanciesResponse = Struct.new(:tenancies, :number_of_pages)

      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def get_tenancies(user_id:, page_number:, number_per_page:, paused: nil)
        uri = URI("#{@api_host}/my-cases")
        uri.query = URI.encode_www_form(
          'user_id' => user_id,
          'page_number' => page_number,
          'number_per_page' => number_per_page,
          'is_paused' => paused
        )

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), "when trying to get_tenancies for UID '#{user_id}'"
        end

        body = JSON.parse(res.body)

        number_of_pages = body.fetch('number_of_pages')
        tenancies = body.fetch('cases').map do |tenancy|
          t = Hackney::Income::Domain::TenancyListItem.new
          t.ref = tenancy['ref']
          t.current_balance = tenancy['current_balance'].gsub(/[^\d\.-]/, '').to_f
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

          if Rails.env.staging?
            Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: t)
          else
            t
          end
        end

        GetTenanciesResponse.new(tenancies, number_of_pages)
      end

      def get_tenancy(tenancy_ref:)
        uri = URI("#{@api_host}/tenancies/#{ERB::Util.url_encode(tenancy_ref)}")

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        tenancy = JSON.parse(res.body)
        tenancy_item = Hackney::Income::Domain::Tenancy.new.tap do |t|
          t.ref = tenancy['tenancy_details']['ref']
          t.tenure = tenancy['tenancy_details']['tenure']
          t.rent = tenancy['tenancy_details']['rent'].gsub(/[^\d\.-]/, '').to_f
          t.service = tenancy['tenancy_details']['service'].gsub(/[^\d\.-]/, '').to_f
          t.other_charge = tenancy['tenancy_details']['other_charge'].gsub(/[^\d\.-]/, '').to_f
          t.current_arrears_agreement_status = tenancy['tenancy_details']['current_arrears_agreement_status']
          t.current_balance = tenancy['tenancy_details']['current_balance'].gsub(/[^\d\.-]/, '').to_f
          t.primary_contact_name = tenancy['tenancy_details']['primary_contact_name']
          t.primary_contact_long_address = tenancy['tenancy_details']['primary_contact_long_address']
          t.primary_contact_postcode = tenancy['tenancy_details']['primary_contact_postcode']

          t.arrears_actions = extract_action_diary(events: tenancy['latest_action_diary_events'])
          t.agreements = extract_agreements(agreements: tenancy['latest_arrears_agreements'])
        end

        return Hackney::Income::Anonymizer.anonymize_tenancy(tenancy: tenancy_item) if Rails.env.staging?
        tenancy_item
      end

      def update_tenancy(tenancy_ref:, is_paused_until:)
        uri = URI.parse(File.join(@api_host, "/tenancies/#{ERB::Util.url_encode(tenancy_ref)}"))
        uri.query = URI.encode_www_form(
          is_paused_until: is_paused_until
        )

        req = Net::HTTP::Patch.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
        res
      end

      def get_contacts_for(tenancy_ref:)
        uri = URI("#{@api_host}/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/contacts")

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        contacts = JSON.parse(res.body)['data']['contacts']

        return [] if contacts.blank? || Rails.env.staging?

        contacts.map do |c|
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
      end

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