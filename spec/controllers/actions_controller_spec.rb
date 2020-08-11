require 'rails_helper'

describe ActionsController do
  let(:list_cases) { spy(Hackney::Income::ListActions) }

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
      get :index, params: { service_area_type: :leasehold }

      expect(assigns(:tenancies)).to all(be_instance_of(Hackney::Income::Domain::LeaseholdActionListItem))
      expect(assigns(:tenancies)).to all(be_valid)
    end

    it 'should pass filter params to the ListCases use case' do
      expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
        'page' => 1,
        'immediate_actions' => 'true'
      ).and_call_original

      expect_any_instance_of(Hackney::Income::ListActions)
          .to receive(:execute)
                  .with(
                    filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams),
                    service_area_type: 'leasehold'
                  )
                  .and_call_original

      get :index, params: { service_area_type: :leasehold }
    end

    it 'should assign page number as an instance variable from the use case response' do
      get :index, params: { service_area_type: :leasehold }

      expect(assigns(:page_number)).to eq(1)
    end

    context 'when visiting page two' do
      it 'should pass filter params for page two to the ListCases use case' do
        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'page' => '2',
          'immediate_actions' => 'true'
        ).and_call_original

        expect_any_instance_of(Hackney::Income::ListActions)
            .to receive(:execute)
                    .with(
                      service_area_type: 'leasehold',
                      filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams)
                    )
                    .and_call_original

        get :index, params: { page: 2, service_area_type: :leasehold }
      end

      it 'should assign page number correctly' do
        get :index, params: { page: 2, service_area_type: :leasehold }

        expect(assigns(:page_number)).to eq(2)
        expect(assigns(:number_of_pages)).to eq(1)
      end

      it 'should show a list of only paused tenancies when requested' do
        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'paused' => 'true',
          'page' => 1,
          'pause_reason' => nil
        ).and_call_original

        expect_any_instance_of(Hackney::Income::ListActions)
            .to receive(:execute)
                    .with(
                      service_area_type: 'leasehold',
                      filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams)
                    )
                    .and_call_original

        get :index, params: { paused: true, service_area_type: :leasehold }

        expect(assigns(:showing_paused_tenancies)).to eq(true)
        expect(assigns(:tenancies)).to all(be_instance_of(Hackney::Income::Domain::LeaseholdActionListItem))
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

        expect_any_instance_of(Hackney::Income::ListActions)
            .to receive(:execute)
                    .with(
                      service_area_type: 'leasehold',
                      filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams)
                    )
                    .and_call_original

        get :index, params: { patch_code: 'W01', service_area_type: :leasehold }
      end
    end

    context 'when filtering by paused' do
      it 'should pass filter params for pause reason to the ListCases use case' do
        expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
          'paused' => 'true',
          'pause_reason' => 'Missing Data',
          'page' => 1
        ).and_call_original

        expect_any_instance_of(Hackney::Income::ListActions)
            .to receive(:execute)
                    .with(
                      service_area_type: 'leasehold',
                      filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams)
                    )
                    .and_call_original

        get :index, params: { paused: true, pause_reason: 'Missing Data', service_area_type: :leasehold }
      end
    end

    context 'When worktray can not be loaded' do
      it 'should show an error message' do
        expect_any_instance_of(Hackney::Income::TenancyGateway)
            .to receive(:get_actions)
                    .and_raise(
                      Exceptions::IncomeApiError.new(Net::HTTPResponse.new(1.1, 400, 'NOT OK')),
                      'BIG ERROR!!'
                    )

        get :index, params: { service_area_type: :leasehold }

        expect(flash[:notice]).to eq('An error occurred while loading your worktray, this may be caused by an Universal Housing outage')
      end
    end
  end
end
