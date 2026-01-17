require 'rails_helper'

RSpec.describe Wishes::Queries::ListWishes, type: :service do
  subject(:call_service) { described_class.call(**params) }

  let!(:wish1) { create(:wish, body: 'First wish', created_at: 1.day.ago) }
  let!(:wish2) { create(:wish, body: 'Second wish', created_at: 2.days.ago) }
  let!(:wish3) { create(:wish, body: 'Third wish', created_at: 3.days.ago) }

  context 'without pagination' do
    let(:params) { {} }

    it 'returns all wishes' do
      result = call_service

      expect(result).to be_success
      expect(result.value!.size).to eq(3)
    end

    it 'orders by created_at desc by default' do
      result = call_service

      expect(result).to be_success
      expect(result.value!).to eq([wish1, wish2, wish3])
    end

    it 'eager loads associations' do
      result = call_service
      wishes = result.value!

      # Verify associations are preloaded
      wishes.each do |wish|
        expect(wish.association(:user).loaded?).to be true
        expect(wish.association(:booking).loaded?).to be true
      end
    end
  end

  context 'with filters' do
    let(:user) { create(:user) }
    let!(:user_wish) { create(:wish, user: user) }
    let(:params) { { filters: { user_id: user.id } } }

    it 'filters wishes by user' do
      result = call_service

      expect(result).to be_success
      expect(result.value!).to contain_exactly(user_wish)
    end
  end

  context 'with state filter' do
    let!(:active_wish) { create(:wish, state: :active) }
    let!(:realised_wish) { create(:wish, state: :realised) }
    let(:params) { { filters: { state: :active } } }

    it 'filters wishes by state' do
      result = call_service

      expect(result).to be_success
      wishes = result.value!
      expect(wishes).to include(active_wish)
      expect(wishes).not_to include(realised_wish)
    end
  end

  context 'with custom order' do
    let(:params) { { order: 'created_at asc' } }

    it 'orders wishes as specified' do
      result = call_service

      expect(result).to be_success
      expect(result.value!).to eq([wish3, wish2, wish1])
    end
  end

  context 'with pagination' do
    let(:params) { { page: 1, per_page: 2 } }

    it 'returns paginated result with metadata' do
      result = call_service

      expect(result).to be_success
      payload = result.value!
      expect(payload[:data].size).to eq(2)
      expect(payload[:metadata][:total_count]).to eq(3)
      expect(payload[:metadata][:page]).to eq(1)
      expect(payload[:metadata][:per_page]).to eq(2)
      expect(payload[:metadata][:total_pages]).to eq(2)
    end

    it 'returns correct first page items' do
      result = call_service
      payload = result.value!
      expect(payload[:data]).to eq([wish1, wish2])
    end
  end

  context 'with page 2' do
    let(:params) { { page: 2, per_page: 2 } }

    it 'returns second page' do
      result = call_service

      expect(result).to be_success
      payload = result.value!
      expect(payload[:data].size).to eq(1)
      expect(payload[:data]).to eq([wish3])
      expect(payload[:metadata][:page]).to eq(2)
    end
  end

  context 'with default pagination (page only)' do
    let(:params) { { page: 1 } }

    it 'uses default per_page of 20' do
      result = call_service

      expect(result).to be_success
      payload = result.value!
      expect(payload[:metadata][:per_page]).to eq(20)
    end
  end

  context 'with per_page only' do
    let(:params) { { per_page: 2 } }

    it 'uses default page of 1' do
      result = call_service

      expect(result).to be_success
      payload = result.value!
      expect(payload[:metadata][:page]).to eq(1)
    end
  end

  context 'with filters, order, and pagination' do
    let(:user) { create(:user) }
    let!(:user_wish1) { create(:wish, user: user, created_at: 1.hour.ago) }
    let!(:user_wish2) { create(:wish, user: user, created_at: 2.hours.ago) }
    let(:params) do
      {
        filters: { user_id: user.id },
        order: 'created_at asc',
        page: 1,
        per_page: 10
      }
    end

    it 'combines all parameters correctly' do
      result = call_service

      expect(result).to be_success
      payload = result.value!
      expect(payload[:data]).to eq([user_wish2, user_wish1])
      expect(payload[:metadata][:total_count]).to eq(2)
    end
  end

  context 'when no wishes match filters' do
    let(:params) { { filters: { user_id: 999_999 } } }

    it 'returns empty array' do
      result = call_service

      expect(result).to be_success
      expect(result.value!).to be_empty
    end
  end

  context 'with pagination on empty results' do
    let(:params) { { filters: { user_id: 999_999 }, page: 1, per_page: 10 } }

    it 'returns empty data with correct metadata' do
      result = call_service

      expect(result).to be_success
      payload = result.value!
      expect(payload[:data]).to be_empty
      expect(payload[:metadata][:total_count]).to eq(0)
      expect(payload[:metadata][:total_pages]).to eq(0)
    end
  end
end
