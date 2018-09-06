require 'rails_helper'

describe PriorityHelper do
  context '#sorted_priority_criteria' do
    let(:criteria) do
      [
        { name: 'Criteria A', display_value: nil, adjustment: 100 },
        { name: 'Criteria B', display_value: nil, adjustment: -50 },
        { name: 'Criteria C', display_value: nil, adjustment: 0 }
      ]
    end

    it 'should sort by adjustment, descending' do
      expect(helper.sorted_priority_criteria(criteria).map { |c| c.fetch(:adjustment) }).to eq([100, 0, -50])
    end

    it 'should return the criteria hashes as they are' do
      sorted = helper.sorted_priority_criteria(criteria)
      criteria.each do |item|
        expect(sorted).to include(item)
      end
    end

    context 'when nil criteria exists' do
      let(:criteria) do
        [
          { name: 'Criteria A', display_value: nil, adjustment: 200 },
          { name: 'Criteria B', display_value: nil, adjustment: nil },
          { name: 'Criteria C', display_value: nil, adjustment: 1 },
          { name: 'Criteria D', display_value: nil, adjustment: -1 },
          { name: 'Criteria E', display_value: nil, adjustment: -50 }
        ]
      end

      it 'should consider it 0' do
        expect(helper.sorted_priority_criteria(criteria).map { |c| c.fetch(:name) }).to eq([
          'Criteria A',
          'Criteria C',
          'Criteria B',
          'Criteria D',
          'Criteria E'
        ])
      end
    end
  end

  context '#display_priority_value' do
    it 'should display false as "NO"' do
      expect(helper.display_priority_value(false)).to eq('NO')
    end

    it 'should display true as "YES"' do
      expect(helper.display_priority_value(true)).to eq('YES')
    end

    it 'should display the value in other cases' do
      expect(helper.display_priority_value(100.0)).to eq('100.0')
    end
  end

  context '#display_priority_adjustment' do
    it 'should display positive integers with a plus' do
      expect(helper.display_priority_adjustment(100)).to eq('+100')
    end

    it 'should display negative integers with a minus' do
      expect(helper.display_priority_adjustment(-100)).to eq('-100')
    end

    it 'should display zero as "N/A"' do
      expect(helper.display_priority_adjustment(0)).to eq('N/A')
    end

    it 'should display nil as "N/A"' do
      expect(helper.display_priority_adjustment(nil)).to eq('N/A')
    end
  end
end
