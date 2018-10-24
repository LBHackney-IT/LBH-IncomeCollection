require 'rails_helper'

describe TenanciesController do
  let(:list_user_assigned_cases) { spy(Hackney::Income::ListUserAssignedCases) }

  before do
    stub_const('Hackney::Income::LessDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
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
    it 'should pause a tenancy case' do
      post :pause, params: { id: 1234567, until_date: Faker::Date.forward(23)}

      expect(assigns(:tenancy)).to be_present
      expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end
  end
end
