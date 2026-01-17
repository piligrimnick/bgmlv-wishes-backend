require 'rails_helper'

RSpec.describe Wishes::Commands::RealiseWish, type: :service do
  subject(:realise_wish) { described_class.call(wish_id: wish.id) }

  let(:wish) { create(:wish, state: :active) }

  describe '#call' do
    it { is_expected.to be_success }

    it 'marks wish as realised' do
      expect(realise_wish.value!.state).to eq('realised')
    end

    it 'reloads wish' do
      expect(realise_wish.value!.reload).to eq(realise_wish.value!)
    end

    context 'when already realised' do
      let(:wish) { create(:wish, state: :realised) }

      it 'keeps wish as realised' do
        expect(realise_wish.value!.state).to eq('realised')
      end
    end

    context 'when cancelled' do
      let(:wish) { create(:wish, state: :cancelled) }

      it 'changes state to realised' do
        expect(realise_wish.value!.state).to eq('realised')
      end
    end

    context 'when wish not found' do
      subject(:realise_wish) { described_class.call(wish_id: 999_999) }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(realise_wish.failure).to eq(:not_found)
      end
    end
  end
end
