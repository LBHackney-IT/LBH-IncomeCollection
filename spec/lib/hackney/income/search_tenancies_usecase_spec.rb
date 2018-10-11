require 'rails_helper'

describe Hackney::Income::SearchTenanciesUsecase do
  let(:search_tenancy_gateway) { Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub.new }

  let(:subject) { described_class.new(search_gateway: search_tenancy_gateway) }

  it 'can search by keyword' do
    res = subject.execute(search_term: 'test')
    expect(res[:tenancies]).to eq([])
  end

  it 'can paginate search' do
    res = subject.execute(search_term: '123456/89', page: 1)
    expect(res[:tenancies].size).to eq(1)
    expect(res[:number_of_pages]).to eq(1)
    expect(res[:number_of_results]).to eq(1)
  end
end
