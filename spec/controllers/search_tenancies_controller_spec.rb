require 'rails_helper'

describe SearchTenanciesController do
  before do
    stub_const('Hackney::Income::SearchTenanciesGateway', Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub)
    stub_authentication
  end

  context '#show' do
    it 'displays an results page when no keyword' do
      get :show

      expect(assigns(:results)).to eq(nil)
      expect(assigns(:search_info)[:page]).to eq(0)
    end
  end

  context 'when searching for ref 123456/89' do
    it 'should return matching result' do
      expect_any_instance_of(Hackney::Income::SearchTenanciesUsecase)
      .to receive(:execute)
          .with(search_term: '123456/89', page: 0)
          .and_call_original

      get :show, params: { keyword: '123456/89' }

      expect(assigns(:results)[:tenancies].length).to eq(1)
      expect(assigns(:results)[:tenancies]).to all(be_instance_of(Hackney::Income::Domain::TenancySearchResult))

      expect(assigns(:results)[:number_of_pages]).to eq(1)
      expect(assigns(:results)[:number_of_results]).to eq(1)

      expect(assigns(:search_info)[:keyword]).to eq('123456/89')
      expect(assigns(:search_info)[:page]).to eq(0)
    end
  end

  it 'should use pass on page number' do
    expect_any_instance_of(Hackney::Income::SearchTenanciesUsecase)
    .to receive(:execute)
        .with(search_term: '123456/89', page: 1)
        .and_call_original

    get :show, params: { keyword: '123456/89', page: 1 }

    expect(assigns(:results)[:tenancies].length).to eq(1)
    expect(assigns(:results)[:tenancies]).to all(be_instance_of(Hackney::Income::Domain::TenancySearchResult))

    expect(assigns(:results)[:number_of_pages]).to eq(1)
    expect(assigns(:results)[:number_of_results]).to eq(1)

    expect(assigns(:search_info)[:keyword]).to eq('123456/89')
    expect(assigns(:search_info)[:page]).to eq(1)
  end
end
