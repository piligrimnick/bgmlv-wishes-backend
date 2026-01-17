require 'rails_helper'

RSpec.describe Friendships::Queries::ListFriends, type: :service do
  subject(:list_friends) { described_class.call(**params) }

  let(:user) { create(:user) }
  let(:friend1) { create(:user) }
  let(:friend2) { create(:user) }
  let(:non_friend) { create(:user) }

  describe '#call' do
    before do
      create(:friendship, :accepted, requester: user, addressee: friend1)
      create(:friendship, :accepted, requester: friend2, addressee: user)
      create(:friendship, :pending, requester: user, addressee: non_friend)
    end

    context 'without pagination' do
      let(:params) { { user_id: user.id } }

      it 'returns success' do
        expect(list_friends).to be_success
      end

      it 'returns accepted friends from both directions' do
        friends = list_friends.value!
        expect(friends.map(&:id)).to contain_exactly(friend1.id, friend2.id)
      end

      it 'does not include pending friendships' do
        friends = list_friends.value!
        expect(friends.map(&:id)).not_to include(non_friend.id)
      end
    end

    context 'with pagination' do
      let(:params) { { user_id: user.id, page: 1, per_page: 1 } }

      it 'returns paginated data' do
        result = list_friends.value!
        expect(result[:data].size).to eq(1)
        expect(result[:metadata][:total_count]).to eq(2)
        expect(result[:metadata][:page]).to eq(1)
        expect(result[:metadata][:per_page]).to eq(1)
        expect(result[:metadata][:total_pages]).to eq(2)
      end
    end
  end
end
