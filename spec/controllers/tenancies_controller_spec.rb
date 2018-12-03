require 'rails_helper'

describe TenanciesController do
  let(:list_user_assigned_cases) { spy(Hackney::Income::ListUserAssignedCases) }

  before do
    stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::TransactionsGateway', Hackney::Income::StubTransactionsGateway)
    stub_const('Hackney::Income::SchedulerGateway', Hackney::Income::StubSchedulerGateway)
    stub_authentication
  end

  context '#index' do
    it 'should be accessible from /worktray' do
      assert_generates '/worktray', controller: 'tenancies', action: 'index'
    end

    it 'should assign a list of valid tenancies' do
      get :index

      expect(assigns(:user_assigned_tenancies)).to all(be_instance_of(Hackney::Income::Domain::TenancyListItem))
      expect(assigns(:user_assigned_tenancies)).to all(be_valid)
    end

    it 'should pass filter params to the ListUserAssignedCases use case' do
      expected_filter_args = { user_id: 123, page_number: 1, count_per_page: 20, paused: false }

      expect_any_instance_of(Hackney::Income::ListUserAssignedCases)
        .to receive(:execute)
        .with(expected_filter_args)
        .and_call_original

      get :index
    end

    it 'should assign page number as an instance variable from the use case response' do
      get :index

      expect(assigns(:page_number)).to eq(1)
    end

    it 'should inform the template not showing paused cases' do
      allow_any_instance_of(Hackney::Income::ListUserAssignedCases)
        .to receive(:execute)
            .with(user_id: 123, page_number: 1, count_per_page: 20, paused: false)
            .and_call_original

      get :index

      expect(assigns(:showing_paused_tenancies)).to eq(false)
    end

    context 'when visiting page two' do
      it 'should pass filter params for page two to the ListUserAssignedCases use case' do
        expected_filter_args = { user_id: 123, page_number: 2, count_per_page: 20, paused: false }

        expect_any_instance_of(Hackney::Income::ListUserAssignedCases)
          .to receive(:execute)
          .with(expected_filter_args)
          .and_call_original

        get :index, params: { page: 2 }
      end

      it 'should assign page number correctly' do
        get :index, params: { page: 2 }

        expect(assigns(:page_number)).to eq(2)
        expect(assigns(:number_of_pages)).to eq(1)
      end

      it 'should show a list of only paused tenancies when requested' do
        expect_any_instance_of(Hackney::Income::ListUserAssignedCases)
        .to receive(:execute)
            .with(user_id: 123, page_number: 1, count_per_page: 20, paused: true)
            .and_call_original

        get :index, params: { paused: true }

        expect(assigns(:showing_paused_tenancies)).to eq(true)
        expect(assigns(:user_assigned_tenancies)).to all(be_instance_of(Hackney::Income::Domain::TenancyListItem))
        expect(assigns(:user_assigned_tenancies)).to all(be_valid)
      end
    end
  end

  context '#show' do
    it 'should assign a valid tenancy' do
      get :show, params: { id: '1234567' }

      expect(assigns(:tenancy)).to be_present
      expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end
  end

  context '#pause' do
    it 'should assign a valid tenancy' do
      get :pause, params: { id: '1234567' }

      expect(assigns(:tenancy)).to be_present
      expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end
  end

  context '#update' do
    let(:future_date_param) { Faker::Time.forward(23).midnight }
    let(:datepicker_input) { future_date_param.strftime('%Y-%m-%d') }

    let(:tenancy_ref) { '1234567' }
    let(:pause_reason) { Faker::Lorem.sentence }
    let(:pause_comment) { Faker::Lorem.paragraph }
    let(:user_id) { Faker::Number.number(2) }
    let(:action_code) { Faker::Internet.slug }

    it 'should call the update tenancy use case correctly' do
      expect_any_instance_of(Hackney::Income::UpdateTenancy).to receive(:execute).with(
        user_id: 123,
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
