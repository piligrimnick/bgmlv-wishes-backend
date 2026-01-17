require 'rails_helper'

RSpec.describe Wishes::Queries::ListVisibleWishes, type: :service do
  subject(:list_visible) { described_class.call(**params) }

  let(:owner) { create(:user) }
  let(:friend) { create(:user) }
  let(:non_friend) { create(:user) }
  let!(:wish1) { create(:wish, user: owner, state: :active) }
  let!(:wish2) { create(:wish, user: owner, state: :active) }
  let!(:realised_wish) { create(:wish, user: owner, state: :realised) }

  before do
    create(:friendship, :accepted, requester: owner, addressee: friend)
  end

  describe '#call' do
    context 'when owner views own wishes' do
      let(:params) { { owner_id: owner.id, viewer_id: owner.id, state: :active } }

      it 'returns success' do
        expect(list_visible).to be_success
      end

      it 'returns all active wishes' do
        result = list_visible.value!
        wishes = result.is_a?(Hash) ? result[:data] : result
        expect(wishes.size).to eq(2)
      end
    end

    context 'when owner views own wishes with string owner_id (from params)' do
      let(:params) { { owner_id: owner.id.to_s, viewer_id: owner.id, state: :active } }

      it 'returns success' do
        expect(list_visible).to be_success
      end

      it 'returns all active wishes' do
        result = list_visible.value!
        wishes = result.is_a?(Hash) ? result[:data] : result
        expect(wishes.size).to eq(2)
      end
    end

    context 'when friend views wishes' do
      let(:params) { { owner_id: owner.id, viewer_id: friend.id, state: :active } }

      it 'returns all active wishes' do
        result = list_visible.value!
        wishes = result.is_a?(Hash) ? result[:data] : result
        expect(wishes.size).to eq(2)
      end
    end

    context 'when non-friend views wishes' do
      let(:params) { { owner_id: owner.id, viewer_id: non_friend.id, state: :active } }

      it 'returns empty array' do
        result = list_visible.value!
        expect(result[:data]).to be_empty
        expect(result[:metadata][:total_count]).to eq(0)
      end
    end

    context 'when unauthenticated user views wishes' do
      let(:params) { { owner_id: owner.id, viewer_id: nil, state: :active } }

      it 'returns empty array' do
        result = list_visible.value!
        expect(result[:data]).to be_empty
      end
    end

    context 'filtering by state' do
      let(:params) { { owner_id: owner.id, viewer_id: owner.id, state: :realised } }

      it 'returns only realised wishes' do
        result = list_visible.value!
        wishes = result.is_a?(Hash) ? result[:data] : result
        expect(wishes.size).to eq(1)
        expect(wishes.first.state).to eq('realised')
      end
    end

    context 'with pagination' do
      let(:params) { { owner_id: owner.id, viewer_id: owner.id, state: :active, page: 1, per_page: 1 } }

      it 'returns paginated data' do
        result = list_visible.value!
        expect(result[:data].size).to eq(1)
        expect(result[:metadata][:total_count]).to eq(2)
      end
    end
  end
end
