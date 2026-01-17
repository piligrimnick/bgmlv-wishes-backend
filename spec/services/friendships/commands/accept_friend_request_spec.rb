require 'rails_helper'

RSpec.describe Friendships::Commands::AcceptFriendRequest, type: :service do
  subject(:accept_request) { described_class.call(**params) }

  let(:requester) { create(:user) }
  let(:addressee) { create(:user) }
  let(:friendship) { create(:friendship, :pending, requester: requester, addressee: addressee) }

  describe '#call' do
    context 'with valid params as addressee' do
      let(:params) { { friendship_id: friendship.id, addressee_id: addressee.id } }

      it 'changes friendship status to accepted' do
        expect { accept_request }.to change { friendship.reload.status }.from('pending').to('accepted')
      end

      it 'returns success' do
        expect(accept_request).to be_success
      end

      it 'returns accepted friendship' do
        result = accept_request.value!
        expect(result.status).to eq('accepted')
      end
    end

    context 'when user is not the addressee' do
      let(:other_user) { create(:user) }
      let(:params) { { friendship_id: friendship.id, addressee_id: other_user.id } }

      it 'returns failure' do
        expect(accept_request).to be_failure
        expect(accept_request.failure).to eq(:forbidden)
      end

      it 'does not change status' do
        expect { accept_request }.not_to change { friendship.reload.status }
      end
    end

    context 'when friendship does not exist' do
      let(:params) { { friendship_id: 999999, addressee_id: addressee.id } }

      it 'returns failure' do
        expect(accept_request).to be_failure
        expect(accept_request.failure).to eq(:not_found)
      end
    end

    context 'when friendship is not pending' do
      let(:accepted_friendship) { create(:friendship, :accepted, requester: requester, addressee: addressee) }
      let(:params) { { friendship_id: accepted_friendship.id, addressee_id: addressee.id } }

      it 'returns failure' do
        expect(accept_request).to be_failure
        expect(accept_request.failure).to eq(:not_pending)
      end
    end
  end
end
