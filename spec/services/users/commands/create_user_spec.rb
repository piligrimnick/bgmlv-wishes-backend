require 'rails_helper'

RSpec.describe Users::Commands::CreateUser, type: :service do
  subject(:create_user) { described_class.call(**params) }

  describe '#call' do
    context 'with valid email and password' do
      let(:params) do
        {
          email: 'test@example.com',
          password: 'password123',
          username: 'testuser',
          firstname: 'Test',
          lastname: 'User'
        }
      end

      it { expect { create_user }.to change(User, :count).by(1) }

      it 'returns success' do
        expect(create_user).to be_success
      end

      it 'creates user with correct attributes' do
        user = create_user.value!

        expect(user.email).to eq('test@example.com')
        expect(user.username).to eq('testuser')
        expect(user.firstname).to eq('Test')
        expect(user.lastname).to eq('User')
      end
    end

    context 'with telegram_id' do
      let(:params) { { telegram_id: '123456789', username: 'telegramuser' } }

      it 'creates user with telegram_id' do
        user = create_user.value!

        expect(user.telegram_id).to eq('123456789')
      end
    end

    context 'with minimal params' do
      let(:params) { {} }

      it { is_expected.to be_success }
    end

    context 'with duplicate email and telegram_id combination' do
      let(:params) do
        {
          email: 'test@example.com',
          telegram_id: '123456',
          password: 'password'
        }
      end

      before { create(:user, email: 'test@example.com', telegram_id: '123456') }

      it 'returns failure' do
        expect(create_user).to be_failure
      end

      it 'does not create user' do
        expect do
          create_user
        rescue StandardError
          nil
        end.not_to change(User, :count)
      end
    end
  end
end
