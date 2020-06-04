require 'rails_helper'

describe Hackney::Income::ListLetterTemplates do
  let(:letters_gateway) { instance_double(Hackney::Income::LettersGateway) }
  let(:user) do
    Hackney::Income::Domain::User.new.tap do |u|
      u.id = Faker::IDNumber.valid
      u.name = Faker::Name.name
      u.email =  Faker::Internet.email
      u.groups = [Faker::Lorem.characters(number: 4)]
    end
  end

  subject { described_class.new(letters_gateway: letters_gateway) }

  it 'uses the notification gateway' do
    expect(letters_gateway).to receive(:get_letter_templates).and_return([])
    subject.execute(user: user)
  end

  context 'when there is one template' do
    let(:name) { Faker::Games::LeagueOfLegends.champion }
    let(:id) { Faker::Games::LeagueOfLegends.rank }

    it 'should return the template with pre-filled values' do
      expect(letters_gateway).to receive(:get_letter_templates).and_return(
        [{
           id: id,
           name: name
         }]
      )

      expect(subject.execute(user: user)).to include(an_object_having_attributes(id: id, name: name))
    end
  end

  context 'when there is more than one template' do
    let(:name) { Faker::Games::LeagueOfLegends.champion }
    let(:id) { Faker::Games::LeagueOfLegends.rank }
    let(:name_1) { Faker::Games::LeagueOfLegends.champion }
    let(:id_1) { Faker::Games::LeagueOfLegends.rank }

    it 'should return all the templates with pre-filled values' do
      expect(letters_gateway).to receive(:get_letter_templates).and_return(
        [{
           id: id,
           name: name
         }, {
          id: id_1,
          name: name_1
         }]
      )

      expect(subject.execute(user: user)).to include(
        an_object_having_attributes(id: id, name: name),
        an_object_having_attributes(id: id_1, name: name_1)
      )
    end

    it 'orders the templates by id' do
      expect(letters_gateway).to receive(:get_letter_templates).and_return(
        [{
           id: 12,
           name: 'second'
         }, {
           id: 0,
           name: 'first'
         }, {
          id: 13,
          name: 'third'
         }]
      )

      result = subject.execute(user: user)
      expect(result.size).to eq(3)
      expect(result[0]).to have_attributes(id: 0, name: 'first')
      expect(result[1]).to have_attributes(id: 12, name: 'second')
      expect(result[2]).to have_attributes(id: 13, name: 'third')
    end
  end
end
