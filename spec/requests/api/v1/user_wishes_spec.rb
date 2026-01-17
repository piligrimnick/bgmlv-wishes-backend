# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Wishes API', type: :request do
  let(:user) { create(:user) }
  let(:token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'read write').token }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/user_wishes/:user_id' do
    context 'when authenticated user views their own wishes' do
      let!(:wish1) { create(:wish, user: user, state: :active) }
      let!(:wish2) { create(:wish, user: user, state: :active) }
      let!(:realised_wish) { create(:wish, user: user, state: :realised) }

      it 'returns all active wishes' do
        get "/api/user_wishes/#{user.id}", params: { page: 1, per_page: 20 }, headers: headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json['data']).to be_an(Array)
        expect(json['data'].size).to eq(2)
        expect(json['data'].pluck('id')).to match_array([wish1.id, wish2.id])
      end

      it 'includes metadata' do
        get "/api/user_wishes/#{user.id}", params: { page: 1, per_page: 20 }, headers: headers

        json = response.parsed_body
        expect(json['metadata']).to be_a(Hash)
        expect(json['metadata']['total_count']).to eq(2)
      end
    end

    context 'when friend views wishes' do
      let(:friend) { create(:user) }
      let!(:friendship) { create(:friendship, :accepted, requester: user, addressee: friend) }
      let(:friend_token) { Doorkeeper::AccessToken.create(resource_owner_id: friend.id, scopes: 'read write').token }
      let(:friend_headers) { { 'Authorization' => "Bearer #{friend_token}" } }
      let!(:wish) { create(:wish, user: user, state: :active) }

      it 'returns user wishes' do
        get "/api/user_wishes/#{user.id}", params: { page: 1, per_page: 20 }, headers: friend_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['data'].size).to eq(1)
        expect(json['data'][0]['id']).to eq(wish.id)
      end
    end

    context 'when non-friend views wishes' do
      let(:stranger) { create(:user) }
      let(:stranger_token) { Doorkeeper::AccessToken.create(resource_owner_id: stranger.id, scopes: 'read write').token }
      let(:stranger_headers) { { 'Authorization' => "Bearer #{stranger_token}" } }
      let!(:wish) { create(:wish, user: user, state: :active) }

      it 'returns empty array' do
        get "/api/user_wishes/#{user.id}", headers: stranger_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['data']).to be_empty
      end
    end
  end

  describe 'GET /api/realised_user_wishes/:user_id' do
    context 'when authenticated user views their own realised wishes' do
      let!(:active_wish) { create(:wish, user: user, state: :active) }
      let!(:realised_wish1) { create(:wish, user: user, state: :realised) }
      let!(:realised_wish2) { create(:wish, user: user, state: :realised) }

      it 'returns only realised wishes' do
        get "/api/realised_user_wishes/#{user.id}", params: { page: 1, per_page: 20 }, headers: headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json['data']).to be_an(Array)
        expect(json['data'].size).to eq(2)
        expect(json['data'].pluck('id')).to match_array([realised_wish1.id, realised_wish2.id])
      end
    end
  end
end
