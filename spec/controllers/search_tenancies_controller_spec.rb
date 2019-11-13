require 'rails_helper'

describe SearchTenanciesController do
  before do
    stub_const('Hackney::Income::SearchTenanciesGateway', Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub)
    sign_in
  end

  it 'should return empty results when no search_term supplied' do
    get :show

    expect(assigns(:results)).to eq(
      tenancies: [],
      number_of_pages: 0,
      number_of_results: 0,
      page: 1,
      address: nil,
      first_name: nil,
      last_name: nil,
      post_code: nil,
      tenancy_ref: nil
    )
  end

  it 'should return matching result' do
    expect_any_instance_of(Hackney::Income::SearchTenanciesUsecase)
    .to receive(:execute)
        .with(
          page: 1,
          first_name: nil,
          last_name: nil,
          address: nil,
          post_code: nil,
          tenancy_ref: '123456/89'
        )
        .and_call_original

    get :show, params: { tenancy_ref: '123456/89' }

    expect(assigns(:results)[:tenancies].length).to eq(1)
    expect(assigns(:results)[:tenancies]).to all(be_instance_of(Hackney::Income::Domain::TenancySearchResult))

    expect(assigns(:results)[:number_of_pages]).to eq(1)
    expect(assigns(:results)[:number_of_results]).to eq(1)

    expect(assigns(:results)[:tenancy_ref]).to eq('123456/89')
    expect(assigns(:results)[:page]).to eq(1)
  end

  it 'should use pass on page number' do
    expect_any_instance_of(Hackney::Income::SearchTenanciesUsecase)
    .to receive(:execute)
        .with(
          page: 2,
          address: 'somewhere',
          first_name: nil,
          last_name: nil,
          post_code: nil,
          tenancy_ref: nil
        )
        .and_call_original

    get :show, params: { address: 'somewhere', page: 2 }

    expect(assigns(:results)[:page]).to eq(2)
  end
end
