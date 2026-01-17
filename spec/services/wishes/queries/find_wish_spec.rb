require 'rails_helper'

RSpec.describe Wishes::Queries::FindWish, type: :service do
  subject(:call_service) { described_class.call(**params) }

  let!(:wish) { create(:wish) }

  context 'when wish exists (by id only)' do
    let(:params) { { id: wish.id } }

    it 'returns success with wish' do
      result = call_service

      expect(result).to be_success
      expect(result.value!).to eq(wish)
    end

    it 'eager loads associations' do
      result = call_service
      found_wish = result.value!

      # Verify associations are preloaded
      expect(found_wish.association(:user).loaded?).to be true
      expect(found_wish.association(:booking).loaded?).to be true
    end
  end

  context 'with filters' do
    let(:user) { create(:user) }
    let!(:user_wish) { create(:wish, user: user, state: :active) }
    let(:params) { { id: user_wish.id, filters: { user_id: user.id } } }

    it 'finds wish matching filters' do
      result = call_service

      expect(result).to be_success
      expect(result.value!).to eq(user_wish)
    end
  end

  context 'when filters do not match' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:user_wish) { create(:wish, user: user) }
    let(:params) { { id: user_wish.id, filters: { user_id: other_user.id } } }

    it 'returns failure with not_found' do
      result = call_service

      expect(result).to be_failure
      expect(result.failure).to eq(:not_found)
    end
  end

  context 'when wish does not exist' do
    let(:params) { { id: 999_999 } }

    it 'returns failure with not_found' do
      result = call_service

      expect(result).to be_failure
      expect(result.failure).to eq(:not_found)
    end
  end

  context 'with state filter' do
    let!(:realised_wish) { create(:wish, state: :realised) }
    let(:params) { { id: realised_wish.id, filters: { state: :realised } } }

    it 'finds wish by state' do
      result = call_service

      expect(result).to be_success
      expect(result.value!).to eq(realised_wish)
    end
  end
end
