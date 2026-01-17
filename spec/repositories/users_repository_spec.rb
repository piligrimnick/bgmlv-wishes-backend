require 'rails_helper'

RSpec.describe UsersRepository do
  let(:repo) { RepositoryRegistry.for(:users) }

  describe '#inactive' do
    let!(:active_user_with_wish) { create(:user) }
    let!(:active_user_with_booking) { create(:user) }
    let!(:inactive_user) { create(:user) }
    let!(:wish) { create(:wish, user: active_user_with_wish) }
    let!(:booking) { create(:booking, user: active_user_with_booking, wish: create(:wish)) }

    it 'returns only users without wishes and without bookings' do
      inactive_users = repo.inactive
      expect(inactive_users).to be_a(UsersCollection)
      expect(inactive_users.first).to be_a(UserStruct)
      
      ids = inactive_users.map(&:id)
      expect(ids).to include(inactive_user.id)
      expect(ids).not_to include(active_user_with_wish.id)
      expect(ids).not_to include(active_user_with_booking.id)
    end
  end
end
