require 'rails_helper'

RSpec.describe Wishes::Commands::BookWish, type: :service do
  subject(:book_wish) { described_class.call(wish_id: wish.id, booker_id: booker.id) }

  let(:wish) { create(:wish) }
  let(:booker) { create(:user) }

  # Create friendship for booking permission
  let(:wishlist_owner) { wish.wishlist.user }

  before do
    create(:friendship, requester: wishlist_owner, addressee: booker, status: :accepted)
  end

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

    context 'when not friends' do
      # Remove friendship setup for this context
      let(:book_wish_no_friend) do
        described_class.call(wish_id: wish.id, booker_id: booker.id)
      end

      before do
        # Override the shared before block friendship creation
        Friendship.where(
          "(requester_id = :a AND addressee_id = :b) OR (requester_id = :b AND addressee_id = :a)",
          a: wishlist_owner.id, b: booker.id
        ).delete_all
      end

      it { expect(book_wish_no_friend).to be_failure }

      it 'returns forbidden error' do
        expect(book_wish_no_friend.failure).to eq(:forbidden)
      end
    end
  end
end
