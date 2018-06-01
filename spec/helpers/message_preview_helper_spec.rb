require 'rails_helper'

describe MessagePreviewHelper do
  context '#message_preview' do
    subject { helper.message_preview(message) }

    context 'when there are newlines in the message' do
      let(:message) { "dear steven,\nplease get in touch" }

      it 'should convert them into <br> tags' do
        expect(subject).to eq("<p>dear steven,\n<br />please get in touch</p>")
      end
    end

    context 'when there are links in the message' do
      let(:message) { 'please visit https://example.com' }

      it 'should convert them into <a> tags' do
        expect(subject).to include('<a href="https://example.com">https://example.com</a>')
      end
    end
  end
end
