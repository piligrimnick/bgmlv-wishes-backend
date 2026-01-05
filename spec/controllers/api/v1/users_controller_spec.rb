require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id, scopes: 'read write') }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
  end

  describe 'PUT #update' do
    context 'when updating own profile' do
      let(:valid_attributes) do
        {
          firstname: 'NewFirst',
          lastname: 'NewLast',
          email: 'new@example.com'
        }
      end

      it 'updates the user' do
        put :update, params: { id: user.id, user: valid_attributes }
        user.reload
        expect(user.firstname).to eq('NewFirst')
        expect(user.lastname).to eq('NewLast')
        expect(user.email).to eq('new@example.com')
      end

      it 'returns success status' do
        put :update, params: { id: user.id, user: valid_attributes }
        expect(response).to have_http_status(:ok)
      end

      it 'allows password update' do
        put :update, params: { id: user.id, user: { password: 'newpassword123' } }
        expect(response).to have_http_status(:ok)
        expect(user.reload.valid_password?('newpassword123')).to be_truthy
      end
    end

    context 'when trying to update another user' do
      it 'does not update the other user' do
        put :update, params: { id: other_user.id, user: { firstname: 'Hacked' } }
        expect(other_user.reload.firstname).not_to eq('Hacked')
      end

      it 'returns forbidden' do
        put :update, params: { id: other_user.id, user: { firstname: 'Hacked' } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #show' do
    context 'when requesting own profile' do
      it 'returns the email' do
        get :show, params: { id: user.id }
        json_response = JSON.parse(response.body)
        expect(json_response['email']).to eq(user.email)
      end
    end

    context 'when requesting another user profile' do
      it 'does not return the email' do
        get :show, params: { id: other_user.id }
        json_response = JSON.parse(response.body)
        expect(json_response).not_to have_key('email')
      end
    end
  end

  describe 'GET #index' do
    let!(:users) { create_list(:user, 15) }

    it 'returns paginated users when using pagination' do
      get :index, params: { page: 1, per_page: 5 }
      json_response = JSON.parse(response.body)
      
      expect(json_response).to have_key('data')
      expect(json_response).to have_key('metadata')
      expect(json_response['data'].size).to eq(5)
      expect(json_response['metadata']['total_count']).to be >= 15
    end

    it 'returns standard array without pagination params' do
      get :index
      json_response = JSON.parse(response.body)
      
      expect(json_response).to be_a(Array)
      expect(json_response.size).to be >= 15
    end
  end
end
