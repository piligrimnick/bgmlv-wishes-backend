require 'rails_helper'

RSpec.describe Users::Queries::FindUser, type: :service do
  subject(:find_user) { described_class.call(id: id) }

  describe '#call' do
    context 'when user exists' do
      let(:user) { create(:user) }
      let(:id) { user.id }

      it { is_expected.to be_success }

      it 'returns the user' do
        expect(find_user.value!).to eq(user)
      end
    end

    context 'when user does not exist' do
      let(:id) { 999_999 }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(find_user.failure).to eq(:not_found)
      end
    end
  end
end
