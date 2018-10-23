require 'net/http'
require 'uri'

module Hackney
  module Income
    class SearchTenanciesGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @search_url = URI.parse(File.join(api_host, '/tenancies/search'))
        @api_key = api_key
      end

      def search(search_term:, page:, page_size:)
        uri = @search_url.dup

        uri.query = URI.encode_www_form(
          'SearchTerm' => search_term,
          'Page' => page,
          'PageSize' => page_size
        )

        request = Net::HTTP::Get.new(uri)
        request['X-Api-Key'] = @api_key

        responce = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

        unless responce.is_a? Net::HTTPSuccess
          raise Exceptions::TenancyApiError.new(responce), "when trying to search tenancies with '#{uri}'"
        end

        marshal(responce.body)
      end

      private

      def marshal(responce_body)
        json = JSON.parse(responce_body)
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
