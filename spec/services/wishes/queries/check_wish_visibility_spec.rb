require 'rails_helper'

RSpec.describe Wishes::Queries::CheckWishVisibility, type: :service do
  subject(:check_visibility) { described_class.call(**params) }

  let(:owner) { create(:user) }
  let(:friend) { create(:user) }
  let(:non_friend) { create(:user) }
  let(:wish) { create(:wish, user: owner) }

  before do
    create(:friendship, :accepted, requester: owner, addressee: friend)
  end

  describe '#call' do
    context 'when viewer is the owner' do
      let(:params) { { wish: wish, viewer_id: owner.id } }

      it 'returns true' do
        expect(check_visibility.value!).to be true
      end
    end

    context 'when viewer is a friend' do
      let(:params) { { wish: wish, viewer_id: friend.id } }

      it 'returns true' do
        expect(check_visibility.value!).to be true
      end
    end

    context 'when viewer is not a friend' do
      let(:params) { { wish: wish, viewer_id: non_friend.id } }

      it 'returns false' do
        expect(check_visibility.value!).to be false
      end
    end

    context 'when viewer is unauthenticated (nil)' do
      let(:params) { { wish: wish, viewer_id: nil } }

      it 'returns false' do
        expect(check_visibility.value!).to be false
      end
    end
  end
end
