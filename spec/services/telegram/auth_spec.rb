require 'rails_helper'

RSpec.describe Telegram::Auth, type: :service do
  subject(:authenticate) { described_class.call(auth_data: auth_data, secure_hash: secure_hash) }

  let(:telegram_token) { 'test_telegram_token' }
  let(:chat_id) { '123456789' }
  let(:auth_data) do
    {
      'id' => chat_id,
      'username' => 'testuser',
      'first_name' => 'Test',
      'last_name' => 'User'
    }
  end

  before { allow(ENV).to receive(:fetch).with('TELEGRAM_TOKEN', nil).and_return(telegram_token) }

  context 'with valid hash' do
    let(:secret_key) { OpenSSL::Digest.new('SHA256').digest(telegram_token) }
    let(:data_string) { auth_data.sort.map { |v| v.join('=') }.join("\n") }
    let(:secure_hash) { OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, data_string) }

    it 'returns success with user' do
      expect(authenticate).to be_success
    end

    it 'creates user with correct attributes' do
      user = authenticate.value!

      expect(user).to be_a(User)
      expect(user.telegram_id).to eq(chat_id)
      expect(user.username).to eq('testuser')
      expect(user.firstname).to eq('Test')
      expect(user.lastname).to eq('User')
    end

    it 'finds existing user on subsequent calls' do
      first_user = authenticate.value!
      second_user = authenticate.value!

      expect(first_user.id).to eq(second_user.id)
    end
  end

  context 'with invalid hash' do
    let(:secure_hash) { 'invalid_hash' }

    it { is_expected.to be_nil }
  end
end
