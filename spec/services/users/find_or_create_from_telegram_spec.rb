require 'rails_helper'

RSpec.describe Users::FindOrCreateFromTelegram, type: :service do
  subject(:call_service) { described_class.call(**params) }

  let(:params) do
    {
      chat_id: 123_456_789,
      username: 'testuser',
      firstname: 'Test',
      lastname: 'User'
    }
  end

  it 'delegates to Users::Commands::FindOrCreateFromTelegram' do
    expect(Users::Commands::FindOrCreateFromTelegram).to receive(:call).with(
      chat_id: 123_456_789,
      username: 'testuser',
      firstname: 'Test',
      lastname: 'User'
    )

    call_service
  end

  it 'returns the result from command' do
    result = call_service

    expect(result).to be_success
    expect(result.value!).to be_a(User)
  end
end
