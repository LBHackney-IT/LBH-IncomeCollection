module Exceptions
  class IncomeApiError < StandardError
    attr_reader :responce
    def initialize(responce)
      super
      @responce = responce
    end

    def to_s
      "[Income API error: Received #{responce.code} responce] #{super}"
    end
  end

  class TenancyApiError < StandardError
    attr_reader :responce
    def initialize(responce)
      super
      @responce = responce
    end

    def to_s
      "[Tenancy API error: Received #{responce.code} responce] #{super}"
    end
  end
end
