require 'rails_helper'

describe Hackney::Income::SqlEventsGateway do
  let(:gateway) { described_class.new }

  context 'when adding a new automated event to a tenancy' do
    subject do
      gateway.create_event(
        tenancy_ref: '000001/01',
        type: 'text_message',
        description: 'Sent a text message: "Rent Reminder"',
        automated: true
      )
    end

    alias_method :create_event, :subject

    context 'and a tenancy record does not exist' do
      before { create_event }

      it 'should create a tenancy object' do
        expect(Hackney::Models::Tenancy.first).to have_attributes(ref: '000001/01')
      end

      it 'should create a tenancy event record' do
        expect(Hackney::Models::TenancyEvent.first).to have_attributes(
          tenancy_id: 1,
          event_type: 'text_message',
          description: 'Sent a text message: "Rent Reminder"',
          automated: true
        )
      end
    end

    context 'and a tenancy record already exists' do
      before do
        Hackney::Models::Tenancy.create!(ref: '000001/01')
        create_event
      end

      it 'should not create a new tenancy object' do
        expect(Hackney::Models::Tenancy.count).to eq(1)
      end
    end
  end

  context 'when retrieving events for a tenancy' do
    subject { gateway.events_for(tenancy_ref: '000001/01') }

    context 'and the tenancy does not exist' do
      it 'should return no events' do
        expect(subject).to eq([])
      end
    end

    context 'and an event has been created' do
      let(:description) { "Visited #{Faker::TwinPeaks.location}" }

      before do
        tenancy = Hackney::Models::Tenancy.create!(ref: '000001/01')
        tenancy.tenancy_events.create!(event_type: 'visit', description: description, automated: false)
      end

      it 'should include the event' do
        expect(subject).to eq([{
          type: 'visit',
          description: description,
          automated: false
        }])
      end
    end

    context 'and several events have been created' do
      let(:locations) do
        tenancy = Hackney::Models::Tenancy.create!(ref: '000001/01')
        (0..2).to_a.map do
          location = Faker::TwinPeaks.location
          tenancy.tenancy_events.create!(
            event_type: "#{location.parameterize.underscore}_visit",
            description: "Visited #{location}",
            automated: Faker::Boolean.boolean
          )
        end
      end

      before { locations }

      it 'should include the event' do
        expect(subject).to eq([
          { type: locations[0].event_type, description: locations[0].description, automated: locations[0].automated },
          { type: locations[1].event_type, description: locations[1].description, automated: locations[1].automated },
          { type: locations[2].event_type, description: locations[2].description, automated: locations[2].automated }
        ])
      end
    end
  end
end
