# Don't include this file in anything but Development as it auto-logs you in!
return unless Rails.env.development?

class DevSessionController < ApplicationController
  skip_before_action :check_authentication

  def new
    jwt_payload = {
      'sub' => '139', # This ID exists in staging...
      'email' => 'hackney.user@test.hackney.gov.uk',
      'iss' => 'Hackney',
      'name' => 'Hackney User',
      'groups' => %w[leasehold-services-group-1 income-collection-group-1],
      'iat' => 1_570_462_732
    }

    jwt_token = JWT.encode(jwt_payload, ENV['HACKNEY_JWT_SECRET'], 'HS256')
    cookies['hackneyToken'] = jwt_token

    redirect_to :root
  end
end
