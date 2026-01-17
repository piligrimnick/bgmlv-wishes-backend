require 'rails_helper'

RSpec.describe Users::Queries::ListInactiveUsers, type: :service do
  subject(:list_inactive_users) { described_class.call }

  describe '#call' do
    context 'when there are inactive users' do
      let!(:inactive_users) { create_list(:user, 2) }

      it { is_expected.to be_success }

      it 'returns inactive users' do
        expect(list_inactive_users.value!).to match_array(inactive_users)
      end
    end

    context 'when user has wishes' do
      let!(:user_with_wishes) { create(:user) }
      let!(:wish) { create(:wish, user: user_with_wishes) }

      it 'excludes users with wishes' do
        expect(list_inactive_users.value!).not_to include(user_with_wishes)
      end
    end

    context 'when user has bookings' do
      let!(:user_with_bookings) { create(:user) }
      let!(:wish) { create(:wish) }
      let!(:booking) { create(:booking, user: user_with_bookings, wish: wish) }

      it 'excludes users with bookings' do
        expect(list_inactive_users.value!).not_to include(user_with_bookings)
      end
    end

    context 'when user has both wishes and bookings' do
      let!(:active_user) { create(:user) }
      let!(:wish) { create(:wish, user: active_user) }
      let!(:another_wish) { create(:wish) }
      let!(:booking) { create(:booking, user: active_user, wish: another_wish) }

      it 'excludes active users' do
        expect(list_inactive_users.value!).not_to include(active_user)
      end
    end

    context 'when there are no inactive users' do
      let!(:user) { create(:user) }

      before { create(:wish, user: user) }

      it 'returns empty array' do
        expect(list_inactive_users.value!).to be_empty
      end
    end
  end
end
