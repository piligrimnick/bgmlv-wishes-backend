require 'rails_helper'

RSpec.describe Friendships::Commands::RemoveFriendship, type: :service do
  subject(:remove_friendship) { described_class.call(**params) }

  let(:requester) { create(:user) }
  let(:addressee) { create(:user) }
  let(:friendship) { create(:friendship, :accepted, requester: requester, addressee: addressee) }

  describe '#call' do
    context 'when requester removes friendship' do
      let(:params) { { friendship_id: friendship.id, user_id: requester.id } }

      it 'deletes the friendship' do
        friendship
        expect { remove_friendship }.to change(Friendship, :count).by(-1)
      end

      it 'returns success' do
        expect(remove_friendship).to be_success
      end
    end

    context 'when addressee removes friendship' do
      let(:params) { { friendship_id: friendship.id, user_id: addressee.id } }

      it 'deletes the friendship' do
        friendship
        expect { remove_friendship }.to change(Friendship, :count).by(-1)
      end

      it 'returns success' do
        expect(remove_friendship).to be_success
      end
    end

    context 'when user is not a participant' do
      let(:other_user) { create(:user) }
      let(:params) { { friendship_id: friendship.id, user_id: other_user.id } }

      it 'returns failure' do
        expect(remove_friendship).to be_failure
        expect(remove_friendship.failure).to eq(:forbidden)
      end

      it 'does not delete friendship' do
        friendship
        expect { remove_friendship }.not_to change(Friendship, :count)
      end
    end

    context 'when friendship is not accepted' do
      let(:pending_friendship) { create(:friendship, :pending, requester: requester, addressee: addressee) }
      let(:params) { { friendship_id: pending_friendship.id, user_id: requester.id } }

      it 'returns failure' do
        expect(remove_friendship).to be_failure
        expect(remove_friendship.failure).to eq(:not_accepted)
      end
    end
  end
end
