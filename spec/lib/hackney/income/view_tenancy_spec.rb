require 'rails_helper'
require 'date'

describe Hackney::Income::ViewTenancy do
  context 'when viewing a tenancy' do
    let!(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub.new }
    let!(:transactions_gateway) { Hackney::Income::StubTransactionsGateway.new }
    let!(:scheduler_gateway) { Hackney::Income::StubSchedulerGateway.new }
    let!(:events_gateway) { Hackney::Income::StubEventsGateway.new }

    let!(:view_tenancy_use_case) do
      described_class.new(
        tenancy_gateway: tenancy_gateway,
        transactions_gateway: transactions_gateway,
        scheduler_gateway: scheduler_gateway,
        events_gateway: events_gateway
      )
    end

    subject do
      view_tenancy_use_case.execute(tenancy_ref: tenancy_ref)
    end

    context 'with a tenancy_ref of 3456789' do
      let!(:tenancy_ref) { '3456789' }

      it 'should contain basic details about the tenancy' do
        expect(subject.ref).to eq('3456789')
        expect(subject.current_balance).to eq(1200.99)
      end

      it 'should include contact details' do
        expect(subject.primary_contact_name).to eq('Ms Diana Prince')
        expect(subject.primary_contact_long_address).to eq('1 Themyscira')
        expect(subject.primary_contact_postcode).to eq('E1 123')
      end

      it 'should contain transactions related to the tenancy' do
        expect(subject.transactions).to include(
          id: '123-456-789',
          timestamp: Time.new(2018, 1, 1, 0, 0, 0),
          tenancy_ref: '3456789',
          description: 'Rent Payment',
          value: -50.00,
          type: 'RPY',
          final_balance: 1200.99
        )
      end

      it 'should order transactions by descending time' do
        timestamps = subject.transactions.map { |t| t.fetch(:timestamp) }
        expect(timestamps).to eq([
          Time.new(2018, 1, 1, 0, 0, 0),
          Time.new(2017, 1, 1, 0, 0, 0),
          Time.new(2015, 1, 1, 0, 0, 0)
        ])
      end

      it 'should include cumulative balance for each transaction' do
        values = subject.transactions.map { |t| t.slice(:value, :final_balance, :type) }
        expect(values).to eq([
          { value: -50.00, final_balance: 1200.99, type: 'RPY' },
          { value: 500.00, final_balance: 1250.99, type: 'RNT' },
          { value: -100.00, final_balance: 750.99, type: 'RPY' }
        ])
      end

      it 'should contain agreements related to the tenancy' do
        expect(subject.agreements.count).to be(1)
        expect(subject.agreements[0]).to be_instance_of(Hackney::Income::Domain::ArrearsAgreement)

        expect(subject.agreements[0].amount).to eq('10.99')
        expect(subject.agreements[0].breached).to eq(false)
        expect(subject.agreements[0].clear_by).to eq('2018-11-01')
        expect(subject.agreements[0].frequency).to eq('weekly')
        expect(subject.agreements[0].start_balance).to eq('99.00')
        expect(subject.agreements[0].start_date).to eq('2018-01-01')
        expect(subject.agreements[0].status).to eq('active')
      end

      it 'should contain arrears actions against the tenancy' do
        expect(subject.arrears_actions.count).to be(1)
        expect(subject.arrears_actions[0]).to be_instance_of(Hackney::Income::Domain::ActionDiaryEntry)

        expect(subject.arrears_actions[0].balance).to eq('100.00')
        expect(subject.arrears_actions[0].code).to eq('GEN')
        expect(subject.arrears_actions[0].type).to eq('general_note')
        expect(subject.arrears_actions[0].date).to eq('2018-01-01')
        expect(subject.arrears_actions[0].comment).to eq('this tenant is in arrears!!!')
        expect(subject.arrears_actions[0].universal_housing_username).to eq('Brainiac')
      end

      context 'when there have been no stored events on the tenancy' do
        it 'should only contain arrears actions' do
          expect(subject.arrears_actions.count).to eq(1)
        end
      end

      context 'when there have been local events on the tenancy' do
        let(:events) do
          (0..Faker::Number.between(1, 10)).to_a.map do
            {
              event_type: Faker::Lovecraft.word,
              description: Faker::Lovecraft.tome,
              automated: Faker::Boolean.boolean
            }
          end
        end

        before do
          events.each_with_index do |event, index|
            year = Time.local(1920 + index)

            Timecop.freeze(year) do
              events_gateway.create_event(
                tenancy_ref: '3456789',
                type: event.fetch(:event_type),
                description: event.fetch(:description),
                automated: event.fetch(:automated)
              )
            end
          end
        end

        it 'should list them as arrears actions' do
          events.each do |event|
            expect(subject.arrears_actions.to_s).to include(
              # pretty sinful way to check some unique fields are properly populated
              event.fetch(:event_type),
              event.fetch(:description)
            )
          end
        end

        it 'should list all arrears actions by time descending' do
          times = subject.arrears_actions.map(&:date)
          expect(times.sort.reverse).to eq(times)
        end
      end

      context 'when there are no scheduled actions against the tenancy' do
        it 'should have an empty list' do
          expect(subject.scheduled_actions).to be_empty
        end
      end

      context 'when there are scheduled actions against the tenancy' do
        let(:date) { Faker::Date.forward }
        let(:description) { Faker::Lorem.sentence }

        before do
          scheduler_gateway.schedule_sms(
            run_at: date,
            tenancy_ref: '3456789',
            description: description
          )
        end

        it 'should list them' do
          expect(subject.scheduled_actions).to eq([{
            scheduled_for: date,
            description: description
          }])
        end
      end
    end
  end
end
