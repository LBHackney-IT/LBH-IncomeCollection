require 'rails_helper'

describe Hackney::Income::TemplateReplacer do
  subject { described_class.new }

  it 'should replace variables within strings with appropriate values' do
    string = 'hello there ((first name)) how are you?'
    variables = { 'first name' => 'Dale' }

    expect(subject.replace(string, variables)).to eq(
      'hello there Dale how are you?'
    )
  end

  it 'should replace multiple variables when present' do
    string = 'hello there ((first name)), it is ((today))'
    variables = { 'first name' => 'Shelly', 'today' => 'Tuesday' }

    expect(subject.replace(string, variables)).to eq(
      'hello there Shelly, it is Tuesday'
    )
  end

  it 'should not break when there are additional parentheses' do
    string = 'what time is it? (((time)))'
    variables = { 'time' => '2pm' }

    expect(subject.replace(string, variables)).to eq(
      'what time is it? (2pm)'
    )
  end
end
