require 'rails_helper'

RSpec.describe Wishes::Commands::BookWish, type: :service do
  subject(:book_wish) { described_class.call(wish_id: wish.id, booker_id: booker.id) }

  let(:wish) { create(:wish) }
  let(:booker) { create(:user) }

  describe '#call' do
    it { is_expected.to be_success }

    it 'creates booking for the wish' do
      booked_wish = book_wish.value!

      expect(booked_wish.booker).to eq(booker)
      expect(booked_wish.booking).to be_present
      expect(booked_wish.booking.user).to eq(booker)
    end

    it 'reloads wish' do
      expect(book_wish.value!.reload).to eq(book_wish.value!)
    end

    context 'when wish already booked' do
      let(:other_booker) { create(:user) }

      before { create(:booking, wish: wish, user: other_booker) }

      it 'updates booking to new booker' do
        expect(book_wish.value!.booker).to eq(booker)
      end
    end

    context 'when wish not found' do
      subject(:book_wish) { described_class.call(wish_id: 999_999, booker_id: booker.id) }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(book_wish.failure).to eq(:not_found)
      end
    end

    context 'when booker not found' do
      subject(:book_wish) { described_class.call(wish_id: wish.id, booker_id: 999_999) }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(book_wish.failure).to eq(:not_found)
      end
    end
  end
end
