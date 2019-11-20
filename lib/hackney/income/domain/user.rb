module Hackney
  module Income
    module Domain
      class User
        attr_accessor :id, :name, :email, :groups

        def leasehold_services?
          groups.join(' ').include?('leasehold')
        end

        def income_collection?
          groups.join(' ').include?('income')
        end

        def to_query(*args)
          as_json.to_query(*args)
        end
      end
    end
  end
end
