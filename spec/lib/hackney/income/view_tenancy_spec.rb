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
        expect(subject.current_balance).to eq('1200.99')
        expect(subject.type).to eq('SEC')
        expect(subject.start_date).to eq(Date.new(2018, 1, 1))
      end

      it 'should include contact details' do
        expect(subject.primary_contact).to eq(
          first_name: 'Diana',
          last_name: 'Prince',
          title: 'Ms',
          contact_number: '0208 123 1234',
          email_address: 'test@example.com'
        )
      end

      it 'should contain the address of the tenancy' do
        expect(subject.address).to eq(
          address_1: '1 Themyscira',
          address_2: 'Hackney',
          address_3: 'London',
          address_4: 'UK',
          post_code: 'E1 123'
        )
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
        expect(subject.agreements).to include(
          status: 'active',
          type: 'court_ordered',
          value: '10.99',
          frequency: 'weekly',
          created_date: Date.new(2017, 11, 1)
        )
      end

      it 'should contain arrears actions against the tenancy' do
        expect(subject.arrears_actions).to include(
          type: 'general_note',
          automated: false,
          user: { name: 'Brainiac' },
          date: Date.new(2018, 1, 1),
          description: 'this tenant is in arrears!!!'
        )
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
            expect(subject.arrears_actions).to include(
              type: event.fetch(:event_type),
              automated: event.fetch(:automated),
              user: nil,
              date: instance_of(Time),
              description: event.fetch(:description)
            )
          end
        end

        it 'should list all arrears actions by time descending' do
          times = subject.arrears_actions.map { |action| action.fetch(:date) }
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
