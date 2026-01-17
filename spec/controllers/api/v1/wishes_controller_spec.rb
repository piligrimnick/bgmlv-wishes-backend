require 'rails_helper'

RSpec.describe Api::V1::WishesController do
  let(:user) { create(:user) }
  let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id, scopes: 'read write') }

  before { allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'GET #user_wishes' do
    let!(:active_wishes) { create_list(:wish, 15, user: user, state: :active) }
    let!(:realised_wishes) { create_list(:wish, 5, user: user, state: :realised) }

    context 'with pagination' do
      before { get :user_wishes, params: { user_id: user.id, page: 1, per_page: 5 } }

      it { expect(response).to have_http_status(:ok) }

      it 'returns paginated active wishes' do
        json = response.parsed_body

        expect(json).to have_key('data')
        expect(json).to have_key('metadata')
        expect(json['data'].size).to eq(5)
      end

      it 'includes correct total count' do
        expect(response.parsed_body['metadata']['total_count']).to eq(15)
      end

      it 'excludes realised wishes' do
        wish_states = response.parsed_body['data'].pluck('state')

        expect(wish_states).to all(eq('active'))
      end
    end
  end

  describe 'GET #realised_user_wishes' do
    let!(:active_wishes) { create_list(:wish, 5, user: user, state: :active) }
    let!(:realised_wishes) { create_list(:wish, 15, user: user, state: :realised) }

    context 'with pagination' do
      before { get :realised_user_wishes, params: { user_id: user.id, page: 1, per_page: 5 } }

      it { expect(response).to have_http_status(:ok) }

      it 'returns paginated realised wishes' do
        json = response.parsed_body

        expect(json).to have_key('data')
        expect(json).to have_key('metadata')
        expect(json['data'].size).to eq(5)
      end

      it 'includes correct total count' do
        expect(response.parsed_body['metadata']['total_count']).to eq(15)
      end

      it 'excludes active wishes' do
        wish_states = response.parsed_body['data'].pluck('state')

        expect(wish_states).to all(eq('realised'))
      end
    end
  end
end
