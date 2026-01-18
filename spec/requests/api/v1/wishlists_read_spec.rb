require 'rails_helper'

RSpec.describe 'Wishlists read access', type: :request do
  def auth_headers_for(user)
    token = create(:doorkeeper_access_token, resource_owner_id: user.id)
    { 'Authorization' => "Bearer #{token.token}" }
  end

  describe 'GET /api/v1/users/:user_id/wishlists' do
    it 'unauthenticated: returns only public wishlists' do
      owner = create(:user)
      public_wishlist = create(:wishlist, user: owner, visibility: :public, name: 'Public')
      _private_wishlist = create(:wishlist, user: owner, visibility: :private, name: 'Private')

      get "/api/users/#{owner.id}/wishlists"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.map { |w| w['id'] }).to contain_exactly(public_wishlist.id)
    end

    it 'authenticated non-friend: returns only public wishlists' do
      owner = create(:user)
      viewer = create(:user)
      public_wishlist = create(:wishlist, user: owner, visibility: :public)
      _private_wishlist = create(:wishlist, user: owner, visibility: :private)

      get "/api/users/#{owner.id}/wishlists", headers: auth_headers_for(viewer)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.map { |w| w['id'] }).to contain_exactly(public_wishlist.id)
    end

    it 'friend: returns public + private wishlists' do
      owner = create(:user)
      friend = create(:user)
      create(:friendship, :accepted, requester: owner, addressee: friend)

      public_wishlist = create(:wishlist, user: owner, visibility: :public)
      private_wishlist = create(:wishlist, user: owner, visibility: :private)

      get "/api/users/#{owner.id}/wishlists", headers: auth_headers_for(friend)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.map { |w| w['id'] }).to contain_exactly(public_wishlist.id, private_wishlist.id)
    end
  end

  describe 'GET /api/v1/wishlists/:id and /api/v1/wishlists/:id/wishes' do
    it 'unauthenticated can view public wishlist + wishes' do
      owner = create(:user)
      wishlist = create(:wishlist, user: owner, visibility: :public)
      wish = create(:wish, user: owner, wishlist: wishlist)

      get "/api/wishlists/#{wishlist.id}"
      expect(response).to have_http_status(:ok)

      get "/api/wishlists/#{wishlist.id}/wishes"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.map { |w| w['id'] }).to include(wish.id)
    end

    it 'unauthenticated cannot view private wishlist' do
      owner = create(:user)
      wishlist = create(:wishlist, user: owner, visibility: :private)

      get "/api/wishlists/#{wishlist.id}"
      expect(response).to have_http_status(:not_found)

      get "/api/wishlists/#{wishlist.id}/wishes"
      expect(response).to have_http_status(:not_found)
    end

    it 'non-friend cannot view private wishlist' do
      owner = create(:user)
      viewer = create(:user)
      wishlist = create(:wishlist, user: owner, visibility: :private)

      get "/api/wishlists/#{wishlist.id}", headers: auth_headers_for(viewer)
      expect(response).to have_http_status(:not_found)

      get "/api/wishlists/#{wishlist.id}/wishes", headers: auth_headers_for(viewer)
      expect(response).to have_http_status(:not_found)
    end

    it 'friend can view private wishlist' do
      owner = create(:user)
      friend = create(:user)
      create(:friendship, :accepted, requester: owner, addressee: friend)

      wishlist = create(:wishlist, user: owner, visibility: :private)
      wish = create(:wish, user: owner, wishlist: wishlist)

      get "/api/wishlists/#{wishlist.id}", headers: auth_headers_for(friend)
      expect(response).to have_http_status(:ok)

      get "/api/wishlists/#{wishlist.id}/wishes", headers: auth_headers_for(friend)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.map { |w| w['id'] }).to include(wish.id)
    end
  end
end
