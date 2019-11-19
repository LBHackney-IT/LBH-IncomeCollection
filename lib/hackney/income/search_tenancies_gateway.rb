require 'net/http'
require 'uri'

module Hackney
  module Income
    class SearchTenanciesGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @search_url = URI.parse(File.join(api_host, '/v2/tenancies/search'))
        @api_key = api_key
      end

      def search(page:, page_size:, first_name:, last_name:, address:, post_code:, tenancy_ref:)
        uri = @search_url.dup
        uri.query = URI.encode_www_form(
          'Page' => page,
          'PageSize' => page_size,
          'FirstName' => first_name,
          'LastName' => last_name,
          'Address' => address,
          'PostCode' => post_code,
          'TenancyRef' => tenancy_ref
        )

        request = Net::HTTP::Get.new(uri)
        request['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(request) }

        unless response.is_a? Net::HTTPSuccess
          raise Exceptions::TenancyApiError.new(response), "when trying to search tenancies with '#{uri}'"
        end

        marshal(response.body)
      end

      private

      def marshal(response_body)
        json = JSON.parse(response_body)
        tenancies = []
        number_of_pages = json.dig('data', 'page_count').to_i
        number_of_results = json.dig('data', 'total_count').to_i
        json.dig('data', 'tenancies')&.each do |tenancy|
          tenancies << Hackney::Income::Domain::TenancySearchResult.new.tap do |td|
            td.ref = tenancy['ref']
            td.property_ref = tenancy['prop_ref']
            td.tenure = tenancy['tenure']
            td.current_balance = tenancy.dig('current_balance', 'value')
            td.primary_contact_name = tenancy.dig('primary_contact', 'name')
            td.primary_contact_short_address = tenancy.dig('primary_contact', 'short_address')
            td.primary_contact_postcode = tenancy.dig('primary_contact', 'postcode')
          end
        end
        { tenancies: tenancies, number_of_pages: number_of_pages, number_of_results: number_of_results }
      end
    end
  end
end
