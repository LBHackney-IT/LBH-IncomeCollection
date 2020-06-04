module MockAuthHelper
  def sign_in(user: nil, groups: [])
    @user ||= Hackney::Income::Domain::User.new.tap do |u|
      u.id = 123
      u.name = Faker::Name.name
      u.email = Faker::Internet.email
      u.groups = groups
    end

    allow(controller).to receive(:current_user).and_return(@user)
  end

  def create_jwt_token(user_id: '100518888746922116647')
    jwt_token = build_jwt_token(user_id: user_id)

    cookie = "hackneyToken=#{jwt_token};"

    if RSpec.current_example.metadata[:js]
      page.visit('/')
      browser = Capybara.current_session.driver.browser
      browser.manage.add_cookie name: 'hackneyToken', value: jwt_token
    else
      page.driver.browser.set_cookie(cookie)
    end

    true
  end

  def build_jwt_token(user_id: nil, groups: nil)
    jwt_payload = {
      'sub' => user_id || Faker::Number.number(digits: 10),
      'email' => 'hackney.user@test.hackney.gov.uk',
      'iss' => 'Hackney',
      'name' => 'Hackney User',
      'groups' => groups || ['income-collection-group-1', 'group 2'],
      'iat' => 1_570_462_732
    }

    JWT.encode(jwt_payload, ENV['HACKNEY_JWT_SECRET'], 'HS256')
  end

  def given_i_am_logged_in
    visit '/'
    find('.header__user')
  end
end
