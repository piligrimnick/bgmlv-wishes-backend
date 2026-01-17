require 'rails_helper'

RSpec.describe Users::Commands::FindOrCreateFromTelegram, type: :service do
  subject(:find_or_create) { described_class.call(**params) }

  let(:params) do
    {
      chat_id: 123_456_789,
      username: 'testuser',
      firstname: 'Test',
      lastname: 'User'
    }
  end

  describe '#call' do
    context 'when user does not exist' do
      it { expect { find_or_create }.to change(User, :count).by(1) }

      it 'returns success' do
        expect(find_or_create).to be_success
      end

      it 'creates user with telegram attributes' do
        user = find_or_create.value!

        expect(user.telegram_id).to eq('123456789')
        expect(user.username).to eq('testuser')
        expect(user.firstname).to eq('Test')
        expect(user.lastname).to eq('User')
      end
    end

    context 'when user already exists' do
      let!(:existing_user) { create(:user, telegram_id: '123456789', username: 'oldusername') }

      it { expect { find_or_create }.not_to change(User, :count) }

      it 'returns existing user' do
        user = find_or_create.value!

        expect(user.id).to eq(existing_user.id)
        expect(user.telegram_id).to eq('123456789')
      end
    end

    context 'with only chat_id' do
      let(:params) { { chat_id: '987654321' } }

      it 'creates user without optional attributes' do
        user = find_or_create.value!

        expect(user.telegram_id).to eq('987654321')
        expect(user.username).to be_nil
        expect(user.firstname).to be_nil
        expect(user.lastname).to be_nil
      end
    end

    context 'when creation fails' do
      before { allow(User).to receive(:create_with).and_raise(ActiveRecord::RecordInvalid.new(User.new)) }

      it { is_expected.to be_failure }
    end
  end
end
