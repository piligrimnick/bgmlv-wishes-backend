require 'rails_helper'

RSpec.describe Api::V1::WishesController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id, scopes: 'read write') }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
  end

  describe 'GET #user_wishes' do
    let!(:active_wishes) { create_list(:wish, 15, user: user, state: :active) }
    let!(:realised_wishes) { create_list(:wish, 5, user: user, state: :realised) }

    it 'returns paginated active wishes' do
      get :user_wishes, params: { user_id: user.id, page: 1, per_page: 5 }
      json_response = JSON.parse(response.body)
      
      expect(json_response).to have_key('data')
      expect(json_response).to have_key('metadata')
      expect(json_response['data'].size).to eq(5)
      expect(json_response['metadata']['total_count']).to eq(15)
    end
  end

  describe 'GET #realised_user_wishes' do
    let!(:active_wishes) { create_list(:wish, 5, user: user, state: :active) }
    let!(:realised_wishes) { create_list(:wish, 15, user: user, state: :realised) }

    it 'returns paginated realised wishes' do
      get :realised_user_wishes, params: { user_id: user.id, page: 1, per_page: 5 }
      json_response = JSON.parse(response.body)
      
      expect(json_response).to have_key('data')
      expect(json_response).to have_key('metadata')
      expect(json_response['data'].size).to eq(5)
      expect(json_response['metadata']['total_count']).to eq(15)
    end
  end
end
