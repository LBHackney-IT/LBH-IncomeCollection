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
      let(:groups) { %w[income-collection-group-1 income-collection-group-2] }

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
      let(:groups) { %w[leasehold-services-group-1 income-collection-group-1] }

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
      let(:groups) { %w[leasehold-services-group-1 leasehold-services-group-2] }

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
      let(:groups) { %w[leasehold-services-group-1 income-collection-group-1] }

      it 'returns true' do
        expect(user.income_collection?).to eq(true)
      end
    end
  end

  describe '#to_query' do
    let(:groups) { %w[group-1 group-2] }
    let(:user) do
      described_class.new.tap do |user|
        user.name = Faker::Name.name
        user.email = Faker::Internet.email
        user.id = Faker::Number.number(digits: 4).to_s
      end
    end

    context 'with no params supplied' do
      it 'returns a string' do
        expect(user.to_query).to be_a(String)
      end

      it "contains the user's ID" do
        expect(user.to_query).to include("id=#{CGI.escape(user.id)}")
      end

      it "contains the user's Name" do
        expect(user.to_query).to include("name=#{CGI.escape(user.name)}")
      end

      it "contains the user's Email" do
        expect(user.to_query).to include("email=#{CGI.escape(user.email)}")
      end

      it "contains the user's Groups" do
        url_groups = user.groups.map { |g| "groups#{CGI.escape('[]')}=#{CGI.escape(g)}" }.join('&')
        expect(user.to_query).to include(url_groups)
      end
    end

    context 'with a namespace param supplied' do
      let(:namespace) { :user }
      let(:user_query) { user.to_query(namespace) }

      it 'returns a string' do
        expect(user_query).to be_a(String)
      end

      it 'contains the namespace' do
        expect(user_query).to include(namespace.to_s)
      end

      it 'formats the namespace in a way that Rails expects' do
        expect(user_query).to include("#{CGI.escape('user[name]')}=#{CGI.escape(user.name)}")
      end
    end
  end

  describe '#as_json' do
    let(:groups) { %w[group-1 group-2] }
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:id) { Faker::Number.number(digits: 4) }
    let(:user) do
      described_class.new.tap do |user|
        user.name = name
        user.email = email
        user.id = id
      end
    end

    it 'orders the attributes' do
      expect(user.as_json.keys).to eq(%w[id name email groups])
    end

    it 'only cares about certain attributes' do
      expect(user.as_json).to eq(
        'id' => id,
        'name' => name,
        'email' => email,
        'groups' => groups
      )
    end
  end

  describe '#to_json' do
    let(:groups) { %w[group-1 group-2] }
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:id) { Faker::Number.number(digits: 4).to_s }
    let(:user) do
      described_class.new.tap do |user|
        user.name = name
        user.email = email
        user.id = id
      end
    end
    let(:expected_json_string) do
      formatted_groups = groups.map { |g| "\"#{g}\"" }.join(',')

      "{\"id\":\"#{id}\",\"name\":\"#{name}\",\"email\":\"#{email}\",\"groups\":[#{formatted_groups}]}"
    end

    it 'returns a consistent json string regardless of rspec seed' do
      expect(user.to_json).to eq(expected_json_string)
    end
  end
end
