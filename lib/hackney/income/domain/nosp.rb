module Hackney
  module Income
    module Domain
      class Nosp
        attr_reader :served_date, :expires_date, :valid_until_date

        def initialize(options)
          options ||= {}

          @served_date = options[:served_date]
          @expires_date = options[:expires_date]
          @valid_until_date = options[:valid_until_date]
          @active = options[:active]
          @valid = options[:valid]
          @in_cool_off_period = options[:in_cool_off_period]
        end

        def served?
          @served_date.present?
        end

        def active?
          @active || false
        end

        def valid?
          @valid || false
        end

        def in_cool_off_period?
          @in_cool_off_period || false
        end
      end
    end
  end
end
