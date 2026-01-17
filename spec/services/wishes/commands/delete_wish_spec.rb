require 'rails_helper'

RSpec.describe Wishes::Commands::DeleteWish, type: :service do
  subject(:delete_wish) { described_class.call(**params) }

  let!(:wish) { create(:wish) }

  describe '#call' do
    context 'with id only' do
      let(:params) { { id: wish.id } }

      it { expect { delete_wish }.to change(Wish, :count).by(-1) }

      it { is_expected.to be_success }

      it 'returns true' do
        expect(delete_wish.value!).to be true
      end
    end

    context 'with filters' do
      let(:user) { create(:user) }
      let!(:user_wish) { create(:wish, user: user) }
      let(:params) { { id: user_wish.id, filters: { user_id: user.id } } }

      it { expect { delete_wish }.to change(Wish, :count).by(-1) }

      it { is_expected.to be_success }
    end

    context 'when filters do not match' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let!(:user_wish) { create(:wish, user: user) }
      let(:params) { { id: user_wish.id, filters: { user_id: other_user.id } } }

      it { expect { delete_wish }.not_to change(Wish, :count) }

      it { is_expected.to be_failure }

      it 'returns not_found error' do
        expect(delete_wish.failure).to eq(:not_found)
      end
    end

    context 'when wish not found' do
      let(:params) { { id: 999_999 } }

      it { is_expected.to be_failure }

      it { expect { delete_wish }.not_to change(Wish, :count) }
    end

    context 'when destroy fails' do
      let(:params) { { id: wish.id } }

      before do
        wish.errors.add(:base, 'Cannot delete')
        allow_any_instance_of(Wish).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new('error', wish))
      end

      it { is_expected.to be_failure }
    end
  end
end
