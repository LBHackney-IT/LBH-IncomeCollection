require 'rails_helper'

describe SearchTenanciesController do
  before do
    stub_const('Hackney::Income::SearchTenanciesGateway', Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub)
    stub_authentication
  end

  it 'should return empty results when no search_term supplied' do
    get :show

    expect(assigns(:results)).to eq(
      tenancies: [],
      number_of_pages: 0,
      number_of_results: 0,
      search_term: '',
      page: 1
    )
  end

  it 'should return matching result' do
    expect_any_instance_of(Hackney::Income::SearchTenanciesUsecase)
    .to receive(:execute)
        .with(
          search_term: '123456/89',
          page: 1,
          first_name: '',
          last_name: '',
          address: '',
          post_code: '',
          tenancy_ref: ''
        )
        .and_call_original

    get :show, params: { search_term: '123456/89' }

    expect(assigns(:results)[:tenancies].length).to eq(1)
    expect(assigns(:results)[:tenancies]).to all(be_instance_of(Hackney::Income::Domain::TenancySearchResult))

    expect(assigns(:results)[:number_of_pages]).to eq(1)
    expect(assigns(:results)[:number_of_results]).to eq(1)

    expect(assigns(:results)[:search_term]).to eq('123456/89')
    expect(assigns(:results)[:page]).to eq(1)
  end

  it 'should use pass on page number' do
    expect_any_instance_of(Hackney::Income::SearchTenanciesUsecase)
    .to receive(:execute)
        .with(
          search_term: 'somthing',
          page: 2,
          first_name: '',
          last_name: '',
          address: '',
          post_code: '',
          tenancy_ref: ''
        )
        .and_call_original

    get :show, params: { search_term: 'somthing', page: 2 }

    expect(assigns(:results)[:page]).to eq(2)
  end
end
