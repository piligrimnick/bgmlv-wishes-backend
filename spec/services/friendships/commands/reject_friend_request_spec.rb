require 'rails_helper'

RSpec.describe Friendships::Commands::RejectFriendRequest, type: :service do
  subject(:reject_request) { described_class.call(**params) }

  let(:requester) { create(:user) }
  let(:addressee) { create(:user) }
  let(:friendship) { create(:friendship, :pending, requester: requester, addressee: addressee) }

  describe '#call' do
    context 'with valid params as addressee' do
      let(:params) { { friendship_id: friendship.id, addressee_id: addressee.id } }

      it 'changes friendship status to rejected' do
        expect { reject_request }.to change { friendship.reload.status }.from('pending').to('rejected')
      end

      it 'returns success' do
        expect(reject_request).to be_success
      end
    end

    context 'when user is not the addressee' do
      let(:other_user) { create(:user) }
      let(:params) { { friendship_id: friendship.id, addressee_id: other_user.id } }

      it 'returns failure' do
        expect(reject_request).to be_failure
        expect(reject_request.failure).to eq(:forbidden)
      end
    end

    context 'when friendship is not pending' do
      let(:accepted_friendship) { create(:friendship, :accepted, requester: requester, addressee: addressee) }
      let(:params) { { friendship_id: accepted_friendship.id, addressee_id: addressee.id } }

      it 'returns failure' do
        expect(reject_request).to be_failure
        expect(reject_request.failure).to eq(:not_pending)
      end
    end
  end
end
