require 'rails_helper'

RSpec.describe Users::Queries::ListUsers, type: :service do
  subject(:list_users) { described_class.call(**params) }

  let!(:user1) { create(:user, username: 'user1') }
  let!(:user2) { create(:user, username: 'user2') }
  let!(:user3) { create(:user, username: 'user3') }

  describe '#call' do
    context 'without pagination' do
      let(:params) { {} }

      it { is_expected.to be_success }

      it 'returns all users' do
        expect(list_users.value!).to contain_exactly(user1, user2, user3)
      end
    end

    context 'with filters' do
      let(:params) { { filters: { username: 'user1' } } }

      it 'filters users' do
        expect(list_users.value!).to contain_exactly(user1)
      end
    end

    context 'with order' do
      let(:params) { { order: 'username desc' } }

      it 'orders users' do
        expect(list_users.value!).to eq([user3, user2, user1])
      end
    end

    context 'with pagination' do
      let(:params) { { page: 1, per_page: 2 } }

      it 'returns paginated data' do
        payload = list_users.value!

        expect(payload[:data].size).to eq(2)
      end

      it 'includes pagination metadata' do
        metadata = list_users.value![:metadata]

        expect(metadata[:total_count]).to eq(3)
        expect(metadata[:page]).to eq(1)
        expect(metadata[:per_page]).to eq(2)
        expect(metadata[:total_pages]).to eq(2)
      end
    end

    context 'with page 2' do
      let(:params) { { page: 2, per_page: 2 } }

      it 'returns second page' do
        payload = list_users.value!

        expect(payload[:data].size).to eq(1)
        expect(payload[:metadata][:page]).to eq(2)
      end
    end

    context 'with default pagination' do
      let(:params) { { page: 1 } }

      it 'uses default per_page of 20' do
        expect(list_users.value![:metadata][:per_page]).to eq(20)
      end
    end

    context 'with per_page only' do
      let(:params) { { per_page: 2 } }

      it 'uses default page of 1' do
        expect(list_users.value![:metadata][:page]).to eq(1)
      end
    end

    context 'with filters and pagination' do
      let(:params) { { filters: { username: 'user1' }, page: 1, per_page: 10 } }

      it 'combines filters and pagination' do
        payload = list_users.value!

        expect(payload[:data]).to contain_exactly(user1)
        expect(payload[:metadata][:total_count]).to eq(1)
      end
    end
  end
end
