require 'rails_helper'

RSpec.describe Wishes::Commands::UpdateWish, type: :service do
  subject(:update_wish) { described_class.call(**params) }

  let!(:wish) { create(:wish, body: 'Old body', url: 'https://old.com') }

  describe '#call' do
    context 'with both body and url' do
      let(:params) { { id: wish.id, body: 'New body', url: 'https://new.com' } }

      it { is_expected.to be_success }

      it 'updates all provided attributes' do
        updated_wish = update_wish.value!

        expect(updated_wish.body).to eq('New body')
        expect(updated_wish.url).to eq('https://new.com')
      end

      it 'reloads wish' do
        expect(update_wish.value!.reload).to eq(update_wish.value!)
      end
    end

    context 'with body only' do
      let(:params) { { id: wish.id, body: 'Updated body' } }

      it 'updates only body' do
        updated_wish = update_wish.value!

        expect(updated_wish.body).to eq('Updated body')
        expect(updated_wish.url).to eq('https://old.com')
      end
    end

    context 'with url only' do
      let(:params) { { id: wish.id, url: 'https://updated.com' } }

      it 'updates only url' do
        updated_wish = update_wish.value!

        expect(updated_wish.body).to eq('Old body')
        expect(updated_wish.url).to eq('https://updated.com')
      end
    end

    context 'without update params' do
      let(:params) { { id: wish.id } }

      it { is_expected.to be_success }
    end

    context 'when wish not found' do
      let(:params) { { id: 999_999, body: 'New body' } }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(update_wish.failure).to eq(:not_found)
      end
    end

    context 'when update fails' do
      let(:params) { { id: wish.id, body: 'New body' } }

      before do
        wish.errors.add(:body, 'is invalid')
        allow_any_instance_of(Wish).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(wish))
      end

      it { is_expected.to be_failure }

      it 'does not update' do
        update_wish
        expect(wish.reload.body).to eq('Old body')
      end
    end
  end
end
