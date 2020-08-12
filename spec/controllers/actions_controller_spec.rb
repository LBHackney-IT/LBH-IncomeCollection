require 'rails_helper'

describe ActionsController do
  let(:list_cases) { spy(Hackney::Income::ListActions) }

  before do
    stub_const('Hackney::Income::ActionsGateway', FakeActionsGateway)
    sign_in
  end

  context '#index' do
    context 'when visiting leasehold worktray' do
      it 'should be accessible from /worktray/v2/leasehold' do
        assert_generates '/worktray/v2/leasehold', controller: 'actions', action: 'index', service_area_type: 'leasehold'
      end

      it 'should assign a list of valid actions' do
        get :index, params: { service_area_type: :leasehold }

        expect(assigns(:actions)).to all(be_instance_of(Hackney::Income::Domain::LeaseholdActionListItem))
        expect(assigns(:actions)).to all(be_valid)
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
                      service_area_type: :leasehold
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
                        service_area_type: :leasehold,
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

        it 'should show a list of only paused actions when requested' do
          expect(Hackney::Income::FilterParams::ListCasesParams).to receive(:new).with(
            'paused' => 'true',
            'page' => 1,
            'pause_reason' => nil
          ).and_call_original

          expect_any_instance_of(Hackney::Income::ListActions)
              .to receive(:execute)
                      .with(
                        service_area_type: :leasehold,
                        filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams)
                      )
                      .and_call_original

          get :index, params: { paused: true, service_area_type: :leasehold }

          expect(assigns(:showing_paused_tenancies)).to eq(true)
          expect(assigns(:actions)).to all(be_instance_of(Hackney::Income::Domain::LeaseholdActionListItem))
          expect(assigns(:actions)).to all(be_valid)
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
                        service_area_type: :leasehold,
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
                        service_area_type: :leasehold,
                        filter_params: instance_of(Hackney::Income::FilterParams::ListCasesParams)
                      )
                      .and_call_original

          get :index, params: { paused: true, pause_reason: 'Missing Data', service_area_type: :leasehold }
        end
      end

      context 'When worktray can not be loaded' do
        it 'should show an error message' do
          expect_any_instance_of(Hackney::Income::ActionsGateway)
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

    context 'when visiting not a leasehold worktray' do
      it 'should redirect back to original rent worktray' do
        get :index, params: { service_area_type: :rent }

        expect(response).to redirect_to worktray_path
      end
    end
  end
end

class FakeActionsGateway
  def initialize(params); end

  def get_actions(filter_params:)
    actions = (0..Faker::Number.between(from: 1, to: 10)).to_a.map do |_n|
      {
            tenancy_ref: "#{Faker::Number.number(digits: 6)}/#{Faker::Number.number(digits: 2)}",
            balance: Faker::Number.decimal(l_digits: 3, r_digits: 3),
            payment_ref: Faker::Number.number(digits: 10).to_s,
            patch_code: Faker::Alphanumeric.alpha(number: 3).upcase,
            action_type: Faker::Music::RockBand.name,
            service_area_type: :leasehold,
            metadata: {
                property_address: "#{Faker::Address.street_address}, London, #{Faker::Address.postcode}",
                lessee: Faker::Name.name,
                tenure_type: Faker::Music::RockBand.name,
                direct_debit_status: ['Live', 'First Payment', 'Cancelled', 'Last Payment'].sample,
                latest_letter: Faker::Alphanumeric.alpha(number: 3).upcase,
                latest_letter_date: Faker::Date.between(from: 20.days.ago, to: Date.today).to_s
            }
        }
    end

    number_of_pages = (actions.count.to_f / filter_params.count_per_page).ceil
    {
        actions: actions,
        number_of_pages: number_of_pages
    }
  end
end
