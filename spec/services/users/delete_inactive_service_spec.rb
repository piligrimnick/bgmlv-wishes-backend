require 'rails_helper'

RSpec.describe Users::DeleteInactiveService do
  describe '.call' do
    let!(:active_user) { create(:user) }
    let!(:inactive_user) { create(:user) }
    let!(:wish) { create(:wish, user: active_user) }

    it 'deletes only inactive users' do
      expect {
        described_class.call
      }.to change(User, :count).by(-1)

      expect(User.exists?(active_user.id)).to be_truthy
      expect(User.exists?(inactive_user.id)).to be_falsey
    end

    it 'returns the count of deleted users' do
      result = described_class.call
      expect(result[:deleted_count]).to eq(1)
    end
  end
end
