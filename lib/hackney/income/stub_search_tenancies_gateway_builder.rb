module Hackney
  module Income
    class StubSearchTenanciesGatewayBuilder
      class << self
        def build_stub(with_tenancies: DEFAULT_TENANCIES)
          build_gateway_class.tap do |gateway_class|
            gateway_class.default_tenancies = with_tenancies
          end
        end

        private

        def build_gateway_class
          Class.new do
            cattr_accessor :default_tenancies

            def initialize(api_host: nil, api_key: nil)
              @tenancies = default_tenancies
            end

            def search(search_term: '', page: 0, page_size: 10)
              res = @tenancies.select { |t| t.ref == search_term }
              {
                tenancies: res,
                number_of_pages: (res.empty? ? 0 : 1),
                number_of_results: (res.empty? ? 0 : 1),
                search_term: search_term,
                page: page
              }
            end
          end
        end

        DEFAULT_TENANCIES = [
          Hackney::Income::Domain::TenancySearchResult.new.tap do |t|
            t.ref = '123456/89'
            t.tenure = '100'
            t.primary_contact_name = 'Mr Test'
          end,
          Hackney::Income::Domain::TenancySearchResult.new.tap do |t|
            t.ref = '654321/11'
            t.tenure = '200'
            t.primary_contact_name = 'Test name'
          end
        ].freeze
        private_constant :DEFAULT_TENANCIES
      end
    end
  end
end
