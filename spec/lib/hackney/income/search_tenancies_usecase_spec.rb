require 'rails_helper'

describe Hackney::Income::SearchTenanciesUsecase do
  let(:search_tenancy_gateway) { Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub.new }

  let(:subject) { described_class.new(search_gateway: search_tenancy_gateway) }

  it 'if no keyword is supplied no search is passed to the gateway' do
    res = subject.execute(search_term: nil)

    expect(res[:tenancies]).to eq([])
    expect(res[:number_of_pages]).to eq(0)
    expect(res[:number_of_results]).to eq(0)
    expect(res[:search_term]).to eq(nil)
    expect(res[:page]).to eq(1)
  end

  it 'can search by keyword' do
    res = subject.execute(search_term: 'test')
    expect(res[:tenancies]).to eq([])
    expect(res[:number_of_pages]).to eq(0)
    expect(res[:number_of_results]).to eq(0)
    expect(res[:search_term]).to eq('test')
    expect(res[:page]).to eq(1)
  end

  it 'can paginate search' do
    res = subject.execute(search_term: '123456/89', page: 3)
    expect(res[:tenancies].size).to eq(1)
    expect(res[:number_of_pages]).to eq(1)
    expect(res[:number_of_results]).to eq(1)
    expect(res[:search_term]).to eq('123456/89')
    expect(res[:page]).to eq(3)
  end

  it 'number less than 1 are bounded to 1' do
    res = subject.execute(search_term: '123456/89', page: 0)
    expect(res[:page]).to eq(1)
  end
end
