require 'rails_helper'

describe TenanciesController do
  let(:list_cases) { spy(Hackney::Income::ListCases) }

  before do
    stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::TransactionsGateway', Hackney::Income::StubTransactionsGateway)
    stub_const('Hackney::Income::GetActionDiaryEntriesGateway', Hackney::Income::StubGetActionDiaryEntriesGateway)
    sign_in
  end

  context '#index' do
    it 'should be accessible from /worktray' do
      assert_generates '/worktray', controller: 'tenancies', action: 'index'
    end

    it 'should assign a list of valid tenancies' do
      get :index

      expect(assigns(:tenancies)).to all(be_instance_of(Hackney::Income::Domain::TenancyListItem))
      expect(assigns(:tenancies)).to all(be_valid)
    end

    it 'should pass filter params to the ListCases use case' do
      expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
        'page' => 1,
        'immediate_actions' => 'true'
      ).and_call_original

      expect_any_instance_of(Hackney::Income::ListCases)
        .to receive(:execute)
        .with(filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams))
        .and_call_original

      get :index
    end

    it 'should assign page number as an instance variable from the use case response' do
      get :index

      expect(assigns(:page_number)).to eq(1)
    end

    it 'should inform the template to only show immediate actions' do
      expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
        'page' => 1,
        'immediate_actions' => 'true'
      ).and_call_original

      allow_any_instance_of(Hackney::Income::ListCases)
        .to receive(:execute)
            .with(filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams))
            .and_call_original

      get :index

      expect(assigns(:showing_paused_tenancies)).to eq(false)
    end

    context 'when visiting page two' do
      it 'should pass filter params for page two to the ListCases use case' do
        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'page' => '2',
          'immediate_actions' => 'true'
        ).and_call_original

        expect_any_instance_of(Hackney::Income::ListCases)
          .to receive(:execute)
          .with(filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams))
          .and_call_original

        get :index, params: { page: 2 }
      end

      it 'should assign page number correctly' do
        get :index, params: { page: 2 }

        expect(assigns(:page_number)).to eq(2)
        expect(assigns(:number_of_pages)).to eq(1)
      end

      it 'should show a list of only paused tenancies when requested' do
        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'paused' => 'true',
          'page' => 1,
          'pause_reason' => nil
        ).and_call_original

        expect_any_instance_of(Hackney::Income::ListCases)
        .to receive(:execute)
            .with(filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams))
            .and_call_original

        get :index, params: { paused: true }

        expect(assigns(:showing_paused_tenancies)).to eq(true)
        expect(assigns(:tenancies)).to all(be_instance_of(Hackney::Income::Domain::TenancyListItem))
        expect(assigns(:tenancies)).to all(be_valid)
      end
    end

    context 'when filtering by patch' do
      it 'should pass filter params for patch to the ListCases use case' do
        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'patch_code' => 'W01',
          'immediate_actions' => 'true',
          'page' => 1
        ).and_call_original

        expect_any_instance_of(Hackney::Income::ListCases)
          .to receive(:execute)
                .with(filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams))
                .and_call_original

        get :index, params: { patch_code: 'W01' }
      end
    end

    context 'when filtering by paused' do
      it 'should pass filter params for pause reason to the ListCases use case' do
        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'paused' => 'true',
          'pause_reason' => 'Missing Data',
          'page' => 1
        ).and_call_original

        expect_any_instance_of(Hackney::Income::ListCases)
          .to receive(:execute)
                .with(filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams))
                .and_call_original

        get :index, params: { paused: true, pause_reason: 'Missing Data' }
      end
    end

    context 'saving filters in cookies' do
      context 'when immediate_actions' do
        it 'should save recommended_actions when has a value' do
          get :index, params: { recommended_actions: 'send_NOSP' }

          filters_cookie = JSON.parse(cookies[:filters]).deep_symbolize_keys!
          expect(filters_cookie[:active_tab][:name]).to eq('immediate_actions')
          expect(filters_cookie[:active_tab][:page]).to eq(1)
          expect(filters_cookie[:active_tab][:filter][:key]).to eq('recommended_actions')
          expect(filters_cookie[:active_tab][:filter][:value]).to eq('send_NOSP')
        end

        it 'can overwrite existing recommended action in cookies' do
          cookies[:filters] = {
            active_tab: {
                name: 'immediate_actions',
                page: 2,
                filter: { key: 'recommended_actions', value: 'send_NOSP' }
            }
          }.to_json

          get :index, params: { recommended_actions: 'Send Letter One' }

          filters_cookie = JSON.parse(cookies[:filters]).deep_symbolize_keys!
          expect(filters_cookie[:active_tab][:name]).to eq('immediate_actions')
          expect(filters_cookie[:active_tab][:page]).to eq(1)
          expect(filters_cookie[:active_tab][:filter][:key]).to eq('recommended_actions')
          expect(filters_cookie[:active_tab][:filter][:value]).to eq('Send Letter One')
        end
      end

      context 'when paused' do
        it 'should save pause_reason with nil if no pause_reason selected' do
          get :index, params: { paused: 'true' }

          filters_cookie = JSON.parse(cookies[:filters]).deep_symbolize_keys!
          expect(filters_cookie[:active_tab][:name]).to eq('paused')
          expect(filters_cookie[:active_tab][:page]).to eq(1)
          expect(filters_cookie[:active_tab][:filter][:key]).to eq('pause_reason')
          expect(filters_cookie[:active_tab][:filter][:value]).to eq(nil)
        end

        it 'should save pause_reason when it has a value' do
          get :index, params: { paused: 'true', pause_reason: 'Deceased' }

          filters_cookie = JSON.parse(cookies[:filters]).deep_symbolize_keys!
          expect(filters_cookie[:active_tab][:name]).to eq('paused')
          expect(filters_cookie[:active_tab][:page]).to eq(1)
          expect(filters_cookie[:active_tab][:filter][:key]).to eq('pause_reason')
          expect(filters_cookie[:active_tab][:filter][:value]).to eq('Deceased')
        end

        it 'can overwrite existing pause_reason in cookies' do
          cookies[:filters] = {
            active_tab: {
                name: 'paused',
                page: 2,
                filter: { key: 'pause_reason', value: 'Deceased' }
            }
          }.to_json

          get :index, params: { paused: 'true', pause_reason: 'Missing Data' }

          filters_cookie = JSON.parse(cookies[:filters]).deep_symbolize_keys!
          expect(filters_cookie[:active_tab][:name]).to eq('paused')
          expect(filters_cookie[:active_tab][:page]).to eq(1)
          expect(filters_cookie[:active_tab][:filter][:key]).to eq('pause_reason')
          expect(filters_cookie[:active_tab][:filter][:value]).to eq('Missing Data')
        end
      end
    end

    context 'when retrieving filters from cookies' do
      it 'should show the next recommended action filter when already set' do
        cookies[:filters] = {
          active_tab: {
              name: 'immediate_actions',
              page: 2,
              filter: { key: 'recommended_actions', value: 'send_NOSP' }
          }
        }.to_json

        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'immediate_actions' => 'true',
          'page' => 2,
          'recommended_actions' => 'send_NOSP'
        ).and_call_original

        get :index, params: {}
      end

      it 'should show page 2 of paused cases when cookie is already set' do
        cookies[:filters] = {
            active_tab: {
                name: 'paused',
                page: 2
            }
        }.to_json

        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'paused' => 'true',
          'page' => 2
        ).and_call_original

        get :index, params: {}
      end

      it 'should show page 3 of paused cases when cookie is already set and next page is called' do
        cookies[:filters] = {
            active_tab: {
                name: 'paused',
                page: 2
            }
        }.to_json

        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'paused' => 'true',
          'page' => '3'
        ).and_call_original

        get :index, params: { page: 3 }
      end
    end

    context 'When worktray can not be loaded' do
      it 'should show an error message' do
        expect_any_instance_of(Hackney::Income::TenancyGateway)
            .to receive(:get_tenancies)
                    .and_raise(
                      Exceptions::IncomeApiError.new(Net::HTTPResponse.new(1.1, 400, 'NOT OK')), 'Failed to send sms: Invalid phone number provided:'
                    )

        get :index

        expect(flash[:notice]).to eq('An error occurred while loading your worktray, this may be caused by an Universal Housing outage')
      end
    end
  end

  context '#pause' do
    it 'should assign a valid tenancy' do
      get :pause, params: { id: '1234567' }

      expect(assigns(:tenancy)).to be_present
      expect(assigns(:pause_tenancy)).to be_present
      expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end

    it 'should show the pause_reason filter when already set' do
      cookies[:filters] = {
        active_tab: {
            name: 'paused',
            page: 2,
            filter: { key: 'pause_reason', value: 'Deceased' }
        }
      }.to_json

      expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
        'paused' => 'true',
        'page' => 2,
        'pause_reason' => 'Deceased'
      ).and_call_original

      get :index, params: {}
    end
  end

  context '#update' do
    let(:future_date_param) { Faker::Time.forward(days: 23).midnight }
    let(:datepicker_input) { future_date_param.strftime('%Y-%m-%d') }

    let(:tenancy_ref) { '1234567' }
    let(:pause_reason) { Faker::Lorem.sentence }
    let(:pause_comment) { Faker::Lorem.paragraph }
    let(:username) { @user.name }
    let(:action_code) { Faker::Internet.slug }

    it 'should call the update tenancy use case correctly' do
      expect_any_instance_of(Hackney::Income::UpdateTenancy).to receive(:execute).with(
        username: username,
        tenancy_ref: tenancy_ref,
        pause_reason: nil,
        pause_comment: pause_comment,
        action_code: action_code,
        is_paused_until_date: future_date_param
      ).and_return(Net::HTTPNoContent.new(1.1, 204, nil))

      patch :update, params: {
        id: tenancy_ref,
        pause_comment: pause_comment,
        action_code: action_code,
        is_paused_until: datepicker_input
      }
    end

    it 'should call redirect me to the tenancy page' do
      patch :update, params: {
        id: tenancy_ref,
        pause_reason: pause_reason,
        pause_comment: pause_comment,
        action_code: action_code,
        is_paused_until: datepicker_input
      }

      expect(response).to redirect_to(tenancy_path(id: tenancy_ref))
    end

    it 'should show me a success message' do
      patch :update, params: {
        id: tenancy_ref,
        pause_reason: pause_reason,
        pause_comment: pause_comment,
        action_code: action_code,
        is_paused_until: datepicker_input
      }

      expect(flash[:notice]).to eq('Successfully paused')
    end

    context 'when an update is unsuccessful' do
      before do
        stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_failing_stub)
      end

      it 'should show me an error message' do
        patch :update, params: {
          id: tenancy_ref,
          pause_reason: pause_reason,
          pause_comment: pause_comment,
          action_code: action_code,
          is_paused_until: datepicker_input
        }

        expect(flash[:notice]).to eq('Unable to pause: Internal server error')
      end
    end
  end
end
