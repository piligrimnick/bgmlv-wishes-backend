require 'rails_helper'

RSpec.describe Wishes::CreateFromTelegram, type: :service do
  subject(:call_service) { described_class.call(user: user, message_text: message_text) }

  let(:user) { { id: create(:user).id } }
  let(:message_text) { 'Test wish text' }

  it 'delegates to Wishes::PrepareFromText and Wishes::Create' do
    expect(Wishes::PrepareFromText).to receive(:call).with(message_text).and_call_original
    expect(Wishes::Create).to receive(:call).with(
      user_id: user[:id],
      wish: kind_of(Hash)
    ).and_call_original

    call_service
  end

  it 'creates a wish' do
    expect { call_service }.to change(Wish, :count).by(1)
  end

  it 'returns the result from Wishes::Create' do
    result = call_service

    expect(result).to be_success
    expect(result.value!).to be_a(Wish)
  end

  context 'with URL in message' do
    let(:message_text) { 'Check this https://example.com' }

    before do
      allow(Utils::ParseUrl).to receive(:call).and_return('https://example.com')
      allow(MetaInspector).to receive(:new).and_return(
        instance_double(
          MetaInspector::Document,
          response: double(status: 200),
          best_title: 'Example Title',
          best_description: 'Example Description',
          canonicals: [{ href: 'https://example.com' }],
          images: double(best: 'https://example.com/image.jpg')
        )
      )
      allow(Utils::DownloadImage).to receive(:call).and_return(nil)
    end

    it 'processes the URL in PrepareFromText' do
      result = call_service

      expect(result).to be_success
      wish = result.value!
      expect(wish.url).to be_present
    end
  end
end
