# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/wishes privacy enforcement', type: :request do
  let(:owner) { create(:user) }
  let(:friend) { create(:user) }
  let(:non_friend) { create(:user) }
  let!(:wish) { create(:wish, user: owner) }

  before do
    create(:friendship, :accepted, requester: owner, addressee: friend)
  end

  describe 'GET /api/user_wishes/:user_id' do
    context 'when viewing as owner' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: owner.id) }

      it 'shows own wishes' do
        get "/api/user_wishes/#{owner.id}", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        wishes = data.is_a?(Hash) ? data['data'] : data
        expect(wishes.size).to eq(1)
      end
    end

    context 'when viewing as friend' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: friend.id) }

      it 'shows friend wishes' do
        get "/api/user_wishes/#{owner.id}", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        wishes = data.is_a?(Hash) ? data['data'] : data
        expect(wishes.size).to eq(1)
      end
    end

    context 'when viewing as non-friend' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: non_friend.id) }

      it 'returns empty array' do
        get "/api/user_wishes/#{owner.id}", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        wishes = data.is_a?(Hash) ? data['data'] : data
        expect(wishes).to be_empty
      end
    end

    context 'when viewing as unauthenticated' do
      it 'returns empty array' do
        get "/api/user_wishes/#{owner.id}"

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        wishes = data.is_a?(Hash) ? data['data'] : data
        expect(wishes).to be_empty
      end
    end
  end

  describe 'PUT /api/wishes/:id/book' do
    context 'when friend tries to book' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: friend.id) }

      it 'allows booking' do
        put "/api/wishes/#{wish.id}/book", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when non-friend tries to book' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: non_friend.id) }

      it 'returns forbidden' do
        put "/api/wishes/#{wish.id}/book", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:forbidden)
        data = JSON.parse(response.body)
        expect(data['error']).to include('friends')
      end
    end
  end

  describe 'PUT /api/wishes/:id (update)' do
    context 'when owner updates' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: owner.id) }

      it 'allows update' do
        put "/api/wishes/#{wish.id}",
            params: { wish: { body: 'Updated' } },
            headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when non-owner updates' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: friend.id) }

      it 'returns forbidden' do
        put "/api/wishes/#{wish.id}",
            params: { wish: { body: 'Updated' } },
            headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/wishes/:id' do
    context 'when owner deletes' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: owner.id) }

      it 'allows deletion' do
        delete "/api/wishes/#{wish.id}", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when non-owner deletes' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: friend.id) }

      it 'returns forbidden' do
        delete "/api/wishes/#{wish.id}", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT /api/wishes/:id/realise' do
    context 'when owner realises' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: owner.id) }

      it 'allows realisation' do
        put "/api/wishes/#{wish.id}/realise", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when non-owner realises' do
      let(:token) { create(:doorkeeper_access_token, resource_owner_id: friend.id) }

      it 'returns forbidden' do
        put "/api/wishes/#{wish.id}/realise", headers: { Authorization: "Bearer #{token.token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
