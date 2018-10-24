module Exceptions
  class IncomeApiError < StandardError
    attr_reader :response
    def initialize(response)
      super
      @response = response
    end

    def to_s
      "[Income API error: Received #{response.code} response] #{super}"
    end
  end

  class TenancyApiError < StandardError
    attr_reader :response
    def initialize(response)
      super
      @response = response
    end

    def to_s
      "[Tenancy API error: Received #{response.code} response] #{super}"
    end
  end
end
