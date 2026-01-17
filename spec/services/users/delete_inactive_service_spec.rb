require 'rails_helper'

RSpec.describe Users::DeleteInactiveService do
  describe '.call' do
    let!(:active_user) { create(:user) }
    let!(:inactive_user) { create(:user) }
    let!(:wish) { create(:wish, user: active_user) }

    it 'deletes only inactive users' do
      expect do
        described_class.call
      end.to change(User, :count).by(-1)

      expect(User).to exist(active_user.id)
      expect(User).not_to exist(inactive_user.id)
    end

    it 'returns the count of deleted users' do
      result = described_class.call
      expect(result).to be_success
      expect(result.value!).to eq(1)
    end
  end
end
