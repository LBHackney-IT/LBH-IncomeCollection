require 'rails_helper'

describe Hackney::Income::CreateEvictionDate do
  let(:eviction_gateway) { instance_double(Hackney::Income::EvictionGateway) }
  let(:create_eviction_params) do
    {
        tenancy_ref: Faker::Lorem.characters(number: 6),
        eviction_date: Faker::Date.between(from: 5.days.ago, to: Date.today)
    }
  end

  subject { described_class.new(eviction_gateway: eviction_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(eviction_gateway).to receive(:create_eviction).with(params: {
        tenancy_ref: create_eviction_params[:tenancy_ref],
        date: create_eviction_params[:eviction_date]
    })

    subject.execute(eviction_params: create_eviction_params)
  end
end
