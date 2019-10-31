module MockAuthHelper
  def sign_in(user: nil, groups: [])
    user ||= {
      id: 123,
      email: Faker::Internet.email,
      name: Faker::Name.name,
      groups: groups
    }

    allow(controller).to receive(:current_user).and_return(user)
  end

  def create_jwt_token(user_id: '100518888746922116647')
    jwt_payload = {
      'sub' => user_id,
      'email' => 'hackney.user@test.hackney.gov.uk',
      'iss' => 'Hackney',
      'name' => 'Hackney User',
      'groups' => ['group 1', 'group 2'],
      'iat' => 1_570_462_732
    }

    jwt_token = JWT.encode(jwt_payload, ENV['HACKNEY_JWT_SECRET'], 'HS256')

    cookie = "hackneyToken=#{jwt_token};"

    page.driver.browser.set_cookie(cookie)

    true
  end

  def given_i_am_logged_in
    visit '/'
    find('.header__user')
  end
end
