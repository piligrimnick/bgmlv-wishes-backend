require 'rails_helper'

RSpec.describe Friendships::Queries::SearchUsers, type: :service do
  subject(:search) { described_class.call(**params) }

  let(:current_user) { create(:user, username: 'current') }
  let!(:john) { create(:user, username: 'john_doe', firstname: 'John', lastname: 'Doe') }
  let!(:jane) { create(:user, username: 'jane_smith', firstname: 'Jane', lastname: 'Smith') }
  let!(:bob) { create(:user, username: 'bob_jones', firstname: 'Bob', lastname: 'Jones') }

  describe '#call' do
    context 'searching by username' do
      let(:params) { { query: 'john', current_user_id: current_user.id } }

      it 'returns matching users' do
        result = search.value!
        expect(result.map(&:username)).to include('john_doe')
      end

      it 'excludes current user' do
        result = search.value!
        expect(result.map(&:id)).not_to include(current_user.id)
      end
    end

    context 'searching by firstname' do
      let(:params) { { query: 'Jane', current_user_id: current_user.id } }

      it 'returns matching users' do
        result = search.value!
        expect(result.map(&:firstname)).to include('Jane')
      end
    end

    context 'searching by lastname' do
      let(:params) { { query: 'Jones', current_user_id: current_user.id } }

      it 'returns matching users' do
        result = search.value!
        expect(result.map(&:lastname)).to include('Jones')
      end
    end

    context 'with pagination' do
      let(:params) { { query: 'o', current_user_id: current_user.id, page: 1, per_page: 2 } }

      it 'returns paginated results' do
        result = search.value!
        expect(result[:data].size).to be <= 2
        expect(result[:metadata]).to include(:total_count, :page, :per_page, :total_pages)
      end
    end

    context 'case insensitive search' do
      let(:params) { { query: 'JOHN', current_user_id: current_user.id } }

      it 'returns results regardless of case' do
        result = search.value!
        expect(result).not_to be_empty
      end
    end
  end
end
