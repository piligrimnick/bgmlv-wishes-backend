require 'rails_helper'

RSpec.describe Wishes::Commands::UnbookWish, type: :service do
  subject(:unbook_wish) { described_class.call(wish_id: wish.id, booker_id: booker.id) }

  let(:wish) { create(:wish) }
  let(:booker) { create(:user) }
  let!(:booking) { create(:booking, wish: wish, user: booker) }

  describe '#call' do
    context 'when booker matches' do
      it { is_expected.to be_success }

      it 'removes the booking' do
        expect { unbook_wish }.to change { wish.reload.booking }.from(booking).to(nil)
      end

      it 'reloads wish' do
        expect(unbook_wish.value!.reload).to eq(unbook_wish.value!)
      end
    end

    context 'when booker does not match' do
      subject(:unbook_wish) { described_class.call(wish_id: wish.id, booker_id: other_user.id) }

      let(:other_user) { create(:user) }

      it { expect { unbook_wish }.not_to(change { wish.reload.booking }) }

      it { is_expected.to be_success }

      it 'keeps booking' do
        expect(unbook_wish.value!.booking).to be_present
      end
    end

    context 'when wish has no booking' do
      subject(:unbook_wish) { described_class.call(wish_id: wish_without_booking.id, booker_id: booker.id) }

      let(:wish_without_booking) { create(:wish) }

      it { is_expected.to be_success }

      it 'has no booking' do
        expect(unbook_wish.value!.booking).to be_nil
      end
    end

    context 'when wish not found' do
      subject(:unbook_wish) { described_class.call(wish_id: 999_999, booker_id: booker.id) }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(unbook_wish.failure).to eq(:not_found)
      end
    end
  end
end
