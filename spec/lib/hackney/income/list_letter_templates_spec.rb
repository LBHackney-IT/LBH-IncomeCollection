require 'rails_helper'

describe Hackney::Income::ListLetterTemplates do
  let(:letters_gateway) { instance_double(Hackney::Income::LettersGateway) }

  subject { described_class.new(letters_gateway: letters_gateway) }

  it 'should use the notification gateway' do
    expect(letters_gateway).to receive(:get_letter_templates).and_return([])
    subject.execute
  end

  context 'when there is one template' do
    let(:name) { Faker::LeagueOfLegends.champion }
    let(:id) { Faker::LeagueOfLegends.rank }

    it 'should return the template with pre-filled values' do
      expect(letters_gateway).to receive(:get_letter_templates).and_return(
        [{
           id: id,
           name: name
         }]
      )

      expect(subject.execute).to include(an_object_having_attributes(id: id, name: name))
    end
  end

  context 'when there is more than one template' do
    let(:name) { Faker::LeagueOfLegends.champion }
    let(:id) { Faker::LeagueOfLegends.rank }
    let(:name_1) { Faker::LeagueOfLegends.champion }
    let(:id_1) { Faker::LeagueOfLegends.rank }

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

      expect(subject.execute).to include(
         an_object_having_attributes(id: id, name: name),
         an_object_having_attributes(id: id_1, name: name_1)
      )
    end
  end
end
