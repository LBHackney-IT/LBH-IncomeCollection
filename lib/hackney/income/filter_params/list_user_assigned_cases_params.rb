module Hackney
  module Income
    module FilterParams
      class ListUserAssignedCasesParams
        attr_reader :paused, :immediate_action, :full_patch, :upcoming_court_dates,
                    :upcoming_evictions, :recommended_actions, :patch_code

        def initialize(options)
          @page_number          = options[:page]
          @count_per_page       = options[:count_per_page]
          @immediate_action     = options[:immediate_action]
          @recommended_actions  = options[:recommended_actions]
          @patch_code           = options[:patch_code]
          @full_patch           = cast_boolean(options[:full_patch])
          @upcoming_court_dates = cast_boolean(options[:upcoming_court_dates])
          @upcoming_evictions   = cast_boolean(options[:upcoming_evictions])
          @paused               = cast_boolean(options[:paused])
        end

        def count_per_page
          @count_per_page&.to_i || 20
        end

        def page_number
          @page_number&.to_i || 1
        end

        def to_params
          {
            page_number: page_number,
            number_per_page: count_per_page,
            is_paused: paused,
            full_patch: full_patch,
            upcoming_court_dates: upcoming_court_dates,
            upcoming_evictions: upcoming_evictions,
            recommended_actions: recommended_actions,
            patch: patch_code
          }.reject { |_k, v| v.nil? }
        end

        private

        def cast_boolean(value)
          return false if value.nil?

          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
