require 'rails_helper'

RSpec.describe Friendships::Commands::CancelFriendRequest, type: :service do
  subject(:cancel_request) { described_class.call(**params) }

  let(:requester) { create(:user) }
  let(:addressee) { create(:user) }
  let(:friendship) { create(:friendship, :pending, requester: requester, addressee: addressee) }

  describe '#call' do
    context 'with valid params as requester' do
      let(:params) { { friendship_id: friendship.id, requester_id: requester.id } }

      it 'deletes the friendship' do
        friendship # ensure it exists
        expect { cancel_request }.to change(Friendship, :count).by(-1)
      end

      it 'returns success' do
        expect(cancel_request).to be_success
      end
    end

    context 'when user is not the requester' do
      let(:other_user) { create(:user) }
      let(:params) { { friendship_id: friendship.id, requester_id: other_user.id } }

      it 'returns failure' do
        expect(cancel_request).to be_failure
        expect(cancel_request.failure).to eq(:forbidden)
      end

      it 'does not delete friendship' do
        friendship
        expect { cancel_request }.not_to change(Friendship, :count)
      end
    end

    context 'when friendship is not pending' do
      let(:accepted_friendship) { create(:friendship, :accepted, requester: requester, addressee: addressee) }
      let(:params) { { friendship_id: accepted_friendship.id, requester_id: requester.id } }

      it 'returns failure' do
        expect(cancel_request).to be_failure
        expect(cancel_request.failure).to eq(:not_pending)
      end
    end
  end
end
