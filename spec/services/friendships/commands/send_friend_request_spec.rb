require 'rails_helper'

RSpec.describe Friendships::Commands::SendFriendRequest, type: :service do
  subject(:send_request) { described_class.call(**params) }

  let(:requester) { create(:user) }
  let(:addressee) { create(:user) }

  describe '#call' do
    context 'with valid params' do
      let(:params) { { requester_id: requester.id, addressee_id: addressee.id } }

      it 'creates a pending friendship' do
        expect { send_request }.to change(Friendship, :count).by(1)
      end

      it 'returns success' do
        expect(send_request).to be_success
      end

      it 'creates friendship with correct attributes' do
        friendship = send_request.value!

        expect(friendship.requester_id).to eq(requester.id)
        expect(friendship.addressee_id).to eq(addressee.id)
        expect(friendship.status).to eq('pending')
      end
    end

    context 'when trying to friend yourself' do
      let(:params) { { requester_id: requester.id, addressee_id: requester.id } }

      it 'returns failure' do
        expect(send_request).to be_failure
        expect(send_request.failure).to eq(:cannot_friend_yourself)
      end

      it 'does not create friendship' do
        expect { send_request }.not_to change(Friendship, :count)
      end
    end

    context 'when requester does not exist' do
      let(:params) { { requester_id: 999999, addressee_id: addressee.id } }

      it 'returns failure' do
        expect(send_request).to be_failure
        expect(send_request.failure).to eq(:requester_not_found)
      end
    end

    context 'when addressee does not exist' do
      let(:params) { { requester_id: requester.id, addressee_id: 999999 } }

      it 'returns failure' do
        expect(send_request).to be_failure
        expect(send_request.failure).to eq(:addressee_not_found)
      end
    end

    context 'when friendship already exists and is accepted' do
      before { create(:friendship, :accepted, requester: requester, addressee: addressee) }

      let(:params) { { requester_id: requester.id, addressee_id: addressee.id } }

      it 'returns failure' do
        expect(send_request).to be_failure
        expect(send_request.failure).to eq(:already_friends)
      end
    end

    context 'when pending request already exists' do
      before { create(:friendship, :pending, requester: requester, addressee: addressee) }

      let(:params) { { requester_id: requester.id, addressee_id: addressee.id } }

      it 'returns failure' do
        expect(send_request).to be_failure
        expect(send_request.failure).to eq(:request_already_sent)
      end
    end

    context 'when mutual pending requests (auto-accept)' do
      before { create(:friendship, :pending, requester: addressee, addressee: requester) }

      let(:params) { { requester_id: requester.id, addressee_id: addressee.id } }

      it 'auto-accepts the existing friendship' do
        expect { send_request }.not_to change(Friendship, :count)
      end

      it 'returns success with accepted friendship' do
        friendship = send_request.value!

        expect(friendship.status).to eq('accepted')
        expect(friendship.requester_id).to eq(addressee.id)
        expect(friendship.addressee_id).to eq(requester.id)
      end
    end

    context 'when friendship was rejected (retry)' do
      before { create(:friendship, :rejected, requester: requester, addressee: addressee) }

      let(:params) { { requester_id: requester.id, addressee_id: addressee.id } }

      it 'resets to pending status' do
        friendship = send_request.value!

        expect(friendship.status).to eq('pending')
      end

      it 'does not create new friendship' do
        expect { send_request }.not_to change(Friendship, :count)
      end
    end
  end
end
