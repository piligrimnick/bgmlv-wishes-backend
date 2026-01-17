require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id, scopes: 'read write') }

  before { allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'GET #index' do
    let!(:users) { create_list(:user, 15) }

    context 'with pagination' do
      before { get :index, params: { page: 1, per_page: 5 } }

      it { expect(response).to have_http_status(:ok) }

      it 'returns paginated data' do
        json = response.parsed_body

        expect(json).to have_key('data')
        expect(json).to have_key('metadata')
        expect(json['data'].size).to eq(5)
      end

      it 'includes total count in metadata' do
        expect(response.parsed_body['metadata']['total_count']).to be >= 15
      end
    end

    context 'without pagination' do
      before { get :index }

      it { expect(response).to have_http_status(:ok) }

      it 'returns array of users' do
        json = response.parsed_body

        expect(json).to be_a(Array)
        expect(json.size).to be >= 15
      end
    end
  end

  describe 'GET #show' do
    context 'for own profile' do
      before { get :show, params: { id: user.id } }

      it { expect(response).to have_http_status(:ok) }

      it 'includes email' do
        expect(response.parsed_body['email']).to eq(user.email)
      end
    end

    context 'for another user profile' do
      before { get :show, params: { id: other_user.id } }

      it { expect(response).to have_http_status(:ok) }

      it 'excludes email' do
        expect(response.parsed_body).not_to have_key('email')
      end
    end
  end

  describe 'PUT #update' do
    let(:valid_attributes) do
      {
        firstname: 'NewFirst',
        lastname: 'NewLast',
        email: 'new@example.com'
      }
    end

    context 'with own profile' do
      before { put :update, params: { id: user.id, user: valid_attributes } }

      it { expect(response).to have_http_status(:ok) }

      it 'updates user attributes' do
        user.reload

        expect(user.firstname).to eq('NewFirst')
        expect(user.lastname).to eq('NewLast')
        expect(user.email).to eq('new@example.com')
      end
    end

    context 'with password update' do
      before { put :update, params: { id: user.id, user: { password: 'newpassword123' } } }

      it { expect(response).to have_http_status(:ok) }

      it 'updates password' do
        expect(user.reload.valid_password?('newpassword123')).to be true
      end
    end

    context 'with another user profile' do
      before { put :update, params: { id: other_user.id, user: { firstname: 'Hacked' } } }

      it { expect(response).to have_http_status(:forbidden) }

      it 'does not update' do
        expect(other_user.reload.firstname).not_to eq('Hacked')
      end
    end
  end
end
