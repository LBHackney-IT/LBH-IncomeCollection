def stub_my_cases_response(override_params = {})
  stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

  response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))

  default_filters = {
    is_paused: false,
    number_per_page: 20,
    page_number: 1,
    full_patch: false,
    patch: nil,
    recommended_actions: nil,
    upcoming_court_dates: false,
    upcoming_evictions: false,
    pause_reason: nil
  }.merge(override_params).reject { |_k, v| v.nil? }

  uri = /cases\?#{default_filters.to_param.gsub('+', '%20')}/

  stub_request(:get, uri)
    .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
    .to_return(status: 200, body: response_json)
end

def stub_action_diary_entries_gateway
  stub_const('Hackney::Income::GetActionDiaryEntriesGateway', Hackney::Income::StubGetActionDiaryEntriesGateway)
end

def stub_tenancy_api_payments(tenancy_ref: '1234567%2F01')
  response_json = { 'payment_transactions': [] }.to_json

  stub_request(:get, "https://example.com/tenancy/api/v1/tenancies/#{tenancy_ref}/payments")
    .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
    .to_return(status: 200, body: response_json)
end

def stub_income_api_show_tenancy(tenancy_ref: '1234567%2F01')
  response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_priority_response.json'))

  stub_request(:get, "https://example.com/income/api/v1/tenancies/#{tenancy_ref}")
    .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
    .to_return(status: 200, body: response_json)
end

def stub_tenancy_api_contacts(tenancy_ref: '1234567%2F01', response: nil)
  response ||= { data: { contacts: [] } }.to_json

  stub_request(:get, "https://example.com/tenancy/api/v1/tenancies/#{tenancy_ref}/contacts")
    .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
    .to_return(status: 200, body: response)
end

def stub_tenancy_api_actions(tenancy_ref: '1234567%2F01', response: nil)
  response ||= { arrears_action_diary_events: [] }.to_json

  stub_request(:get, "https://example.com/tenancy/api/v1/tenancies/#{tenancy_ref}/actions")
    .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
    .to_return(status: 200, body: response)
end

def stub_tenancy_api_tenancy(tenancy_ref: '1234567%2F01')
  response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_response.json'))

  stub_request(:get, "https://example.com/tenancy/api/v1/tenancies/#{tenancy_ref}")
    .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
    .to_return(status: 200, body: response_json)
end
