module Hackney
  module API
    class ContactsGateway
      def get_contact(ref)
        HTTParty.get()
      end
    end
  end
end
