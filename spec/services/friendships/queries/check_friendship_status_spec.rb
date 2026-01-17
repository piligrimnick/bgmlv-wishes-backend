require 'rails_helper'

RSpec.describe Friendships::Queries::CheckFriendshipStatus, type: :service do
  subject(:check_status) { described_class.call(**params) }

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  describe '#call' do
    context 'when no friendship exists' do
      let(:params) { { user_id: user1.id, other_user_id: user2.id } }

      it 'returns status none' do
        result = check_status.value!
        expect(result[:status]).to eq(:none)
        expect(result[:friendship]).to be_nil
      end
    end

    context 'when outgoing pending request' do
      before { create(:friendship, :pending, requester: user1, addressee: user2) }

      let(:params) { { user_id: user1.id, other_user_id: user2.id } }

      it 'returns outgoing_pending status' do
        result = check_status.value!
        expect(result[:status]).to eq('outgoing_pending')
        expect(result[:friendship]).to be_present
      end
    end

    context 'when incoming pending request' do
      before { create(:friendship, :pending, requester: user2, addressee: user1) }

      let(:params) { { user_id: user1.id, other_user_id: user2.id } }

      it 'returns incoming_pending status' do
        result = check_status.value!
        expect(result[:status]).to eq('incoming_pending')
      end
    end

    context 'when friendship is accepted' do
      before { create(:friendship, :accepted, requester: user1, addressee: user2) }

      let(:params) { { user_id: user1.id, other_user_id: user2.id } }

      it 'returns outgoing_accepted status' do
        result = check_status.value!
        expect(result[:status]).to eq('outgoing_accepted')
      end
    end
  end
end
