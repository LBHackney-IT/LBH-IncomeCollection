require 'rails_helper'

describe Hackney::Income::Domain::User do
  let(:user) { described_class.new }

  before do
    user.groups = groups
  end

  describe '#leasehold_services?' do
    context 'when there are no groups' do
      let(:groups) { [] }

      it 'returns false' do
        expect(user.leasehold_services?).to eq(false)
      end
    end

    context 'when there is a group without the word "leasehold"' do
      let(:groups) { ['income-collection-group-1'] }

      it 'returns false' do
        expect(user.leasehold_services?).to eq(false)
      end
    end

    context 'when there are groups without the word "leasehold"' do
      let(:groups) { ['income-collection-group-1', 'income-collection-group-2'] }

      it 'returns false' do
        expect(user.leasehold_services?).to eq(false)
      end
    end

    context 'when there is a group with the word "leasehold"' do
      let(:groups) { ['leasehold-services-group-1'] }

      it 'returns true' do
        expect(user.leasehold_services?).to eq(true)
      end
    end

    context 'when there is are groups with one with the word "leasehold"' do
      let(:groups) { ['leasehold-services-group-1', 'income-collection-group-1'] }

      it 'returns true' do
        expect(user.leasehold_services?).to eq(true)
      end
    end
  end

  describe '#income_collection??' do
    context 'when there are no groups' do
      let(:groups) { [] }

      it 'returns false' do
        expect(user.income_collection?).to eq(false)
      end
    end

    context 'when there is a group without the word "income"' do
      let(:groups) { ['leasehold-services-group-1'] }

      it 'returns true' do
        expect(user.income_collection?).to eq(false)
      end
    end

    context 'when there are groups without the word "income"' do
      let(:groups) { ['leasehold-services-group-1', 'leasehold-services-group-2'] }

      it 'returns false' do
        expect(user.income_collection?).to eq(false)
      end
    end

    context 'when there is a group with the word "leasehold"' do
      let(:groups) { ['income-collection-group-1'] }

      it 'returns false' do
        expect(user.income_collection?).to eq(true)
      end
    end

    context 'when there is are groups with one with the word "income"' do
      let(:groups) { ['leasehold-services-group-1', 'income-collection-group-1'] }

      it 'returns true' do
        expect(user.income_collection?).to eq(true)
      end
    end
  end
end
