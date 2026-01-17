require 'rails_helper'

RSpec.describe Users::Commands::UpdateUser, type: :service do
  subject(:update_user) { described_class.call(**params) }

  let!(:user) { create(:user, email: 'old@example.com', username: 'olduser') }

  describe '#call' do
    context 'with all attributes' do
      let(:params) do
        {
          id: user.id,
          email: 'new@example.com',
          username: 'newuser',
          firstname: 'New',
          lastname: 'Name'
        }
      end

      it 'updates all provided attributes' do
        updated_user = update_user.value!

        expect(updated_user.email).to eq('new@example.com')
        expect(updated_user.username).to eq('newuser')
        expect(updated_user.firstname).to eq('New')
        expect(updated_user.lastname).to eq('Name')
      end

      it 'reloads the user' do
        expect(update_user.value!.reload).to eq(update_user.value!)
      end
    end

    context 'with partial attributes' do
      let(:params) { { id: user.id, username: 'newusername' } }

      it 'updates only provided fields' do
        updated_user = update_user.value!

        expect(updated_user.username).to eq('newusername')
        expect(updated_user.email).to eq('old@example.com')
      end
    end

    context 'with password' do
      let(:params) { { id: user.id, password: 'newpassword123' } }

      it 'updates password' do
        updated_user = update_user.value!

        expect(updated_user.valid_password?('newpassword123')).to be true
      end
    end

    context 'when user not found' do
      let(:params) { { id: 999_999, email: 'test@example.com' } }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(update_user.failure).to eq(:not_found)
      end
    end

    context 'without update params' do
      let(:params) { { id: user.id } }

      it { is_expected.to be_success }
    end
  end
end
