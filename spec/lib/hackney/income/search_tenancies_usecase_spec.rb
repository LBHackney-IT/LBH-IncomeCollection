require 'rails_helper'

describe Hackney::Income::SearchTenanciesUsecase do
  let(:search_tenancy_gateway) { Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub.new }

  let(:subject) { described_class.new(search_gateway: search_tenancy_gateway) }

  it 'if nothing is supplied no search is passed to the gateway' do
    res = subject.execute(
      first_name: nil,
      last_name: nil,
      address: nil,
      post_code: nil,
      tenancy_ref: nil
    )

    expect(res[:tenancies]).to eq([])
    expect(res[:number_of_pages]).to eq(0)
    expect(res[:number_of_results]).to eq(0)
    expect(res[:first_name]).to eq(nil)
    expect(res[:last_name]).to eq(nil)
    expect(res[:address]).to eq(nil)
    expect(res[:post_code]).to eq(nil)
    expect(res[:tenancy_ref]).to eq(nil)
    expect(res[:page]).to eq(1)
  end

  it 'can search by first name' do
    res = subject.execute(first_name: 'El')
    expect(res[:tenancies]).to eq([])
    expect(res[:number_of_pages]).to eq(0)
    expect(res[:number_of_results]).to eq(0)
    expect(res[:first_name]).to eq('El')
    expect(res[:page]).to eq(1)
  end

  it 'can search by last name' do
    res = subject.execute(last_name: 'Smith')
    expect(res[:tenancies]).to eq([])
    expect(res[:number_of_pages]).to eq(0)
    expect(res[:number_of_results]).to eq(0)
    expect(res[:last_name]).to eq('Smith')
    expect(res[:page]).to eq(1)
  end

  it 'can search by address' do
    res = subject.execute(address: '1 Hillman st')
    expect(res[:tenancies]).to eq([])
    expect(res[:number_of_pages]).to eq(0)
    expect(res[:number_of_results]).to eq(0)
    expect(res[:address]).to eq('1 Hillman st')
    expect(res[:page]).to eq(1)
  end

  it 'can search by post code' do
    res = subject.execute(post_code: 'E8 1DY')
    expect(res[:tenancies]).to eq([])
    expect(res[:number_of_pages]).to eq(0)
    expect(res[:number_of_results]).to eq(0)
    expect(res[:post_code]).to eq('E8 1DY')
    expect(res[:page]).to eq(1)
  end

  it 'can search by tenancy ref' do
    res = subject.execute(tenancy_ref: '123456/89')
    expect(res[:tenancies].size).to eq(1)
    expect(res[:number_of_pages]).to eq(1)
    expect(res[:number_of_results]).to eq(1)
    expect(res[:tenancy_ref]).to eq('123456/89')
    expect(res[:page]).to eq(1)
  end

  it 'can paginate search' do
    res = subject.execute(tenancy_ref: '123456/89', page: 3)
    expect(res[:tenancies].size).to eq(1)
    expect(res[:number_of_pages]).to eq(1)
    expect(res[:number_of_results]).to eq(1)
    expect(res[:tenancy_ref]).to eq('123456/89')
    expect(res[:page]).to eq(3)
  end

  it 'number less than 1 are bounded to 1' do
    res = subject.execute(tenancy_ref: '123456/89', page: 0)
    expect(res[:page]).to eq(1)
  end
end
