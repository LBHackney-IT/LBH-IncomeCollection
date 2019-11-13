require 'rails_helper'

describe 'Viewing the Worktray', type: :request do
  before do
    jwt_token = build_jwt_token(groups: groups)
    cookies['hackneyToken'] = jwt_token

    stub_my_cases_response
  end

  context 'with a leasehold services user' do
    let(:groups) { ['leasehold-services-group-1'] }

    it "doesn't render the worktray tabs" do
      get worktray_path

      expect(response).not_to render_template('tenancies/worktray/tabs')
    end

    it "doesn't render the worktray table" do
      get worktray_path

      expect(response).not_to render_template('tenancies/worktray/worktray_table')
    end

    it 'does render the leasehold button' do
      get worktray_path

      expect(response).not_to render_template('leasehold/buttons')
    end
  end

  context 'with a income collection user' do
    let(:groups) { ['income-collection-group-1'] }

    it 'does render the worktray tabs' do
      get worktray_path

      expect(response).not_to render_template('tenancies/worktray/tabs')
    end

    it 'does render the worktray table' do
      get worktray_path

      expect(response).not_to render_template('tenancies/worktray/worktray_table')
    end

    it 'does not render the leasehold button' do
      get worktray_path

      expect(response).not_to render_template('leasehold/buttons')
    end
  end

  private

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
      upcoming_evictions: false
    }.merge(override_params).reject { |_k, v| v.nil? }

    uri = /cases\?#{default_filters.to_param}/

    stub_request(:get, uri)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
