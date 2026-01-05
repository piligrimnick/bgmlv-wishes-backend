require 'rails_helper'

RSpec.describe ApplicationRepository do
  # Используем UsersRepository как реализацию для тестов, так как ApplicationRepository абстрактный по сути
  let(:gateway) { User }
  let(:collection) { UsersCollection }
  let(:struct) { UserStruct }
  let(:repository) { UsersRepository.new(gateway: gateway, collection: collection, struct: struct) }

  describe '#all' do
    let!(:user1) { create(:user, created_at: 1.day.ago) }
    let!(:user2) { create(:user, created_at: 2.days.ago) }
    let!(:user3) { create(:user, created_at: 3.days.ago) }

    context 'without pagination' do
      it 'returns all users as structurized collection' do
        result = repository.all
        expect(result).to be_a(Array)
        expect(result.size).to eq(3)
        expect(result.first).to be_a(UserStruct)
      end
    end

    context 'with pagination params' do
      it 'returns paginated result with metadata' do
        # Pagination support not implemented yet, expecting failure or default behavior initially
        # But since we are doing TDD, I'll write the expectation for the NEW behavior
        
        # Expecting result to serve as { data: [...], metadata: { total_count: ... } }
        # once we implement pagination
        result = repository.all(page: 1, per_page: 2)
        
        # Structure assertion
        expect(result).to have_key(:data)
        expect(result).to have_key(:metadata)
        
        # Data assertion
        expect(result[:data].size).to eq(2)
        expect(result[:data].first).to be_a(UserStruct)
        
        # Metadata assertion
        expect(result[:metadata][:total_count]).to eq(3)
        expect(result[:metadata][:page]).to eq(1)
        expect(result[:metadata][:per_page]).to eq(2)
      end

      it 'returns second page correctly' do
        result = repository.all(page: 2, per_page: 2)
        
        expect(result[:data].size).to eq(1)
        expect(result[:metadata][:total_count]).to eq(3)
        expect(result[:metadata][:page]).to eq(2)
      end
    end
  end

  describe '#filter' do
    let!(:user1) { create(:user, email: 'test1@example.com') }
    let!(:user2) { create(:user, email: 'test2@example.com') }
    let!(:user3) { create(:user, email: 'other@example.com') }

    it 'returns paginated filtered results' do
      result = repository.filter({ email: 'test1@example.com' }, page: 1, per_page: 10)
      
      expect(result[:data].size).to eq(1)
      expect(result[:data].first.email).to eq('test1@example.com')
      expect(result[:metadata][:total_count]).to eq(1)
    end
  end
end
