# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Wishlists API', type: :request do
  let(:owner) { create(:user) }
  let(:user_id) { owner.id }
  let(:viewer) { create(:user) }
  let(:token) { Doorkeeper::AccessToken.create(resource_owner_id: viewer.id, scopes: 'read write').token }
  let(:Authorization) { "Bearer #{token}" }

  let!(:public_wishlist) { create(:wishlist, user: owner, visibility: :public, name: 'Public') }
  let!(:private_wishlist) { create(:wishlist, user: owner, visibility: :private, name: 'Private') }

  let(:id) { public_wishlist.id }

  path '/api/users/{user_id}/wishlists' do
    get 'List user wishlists (public/private visibility)' do
      tags 'Wishlists'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :integer, description: 'Owner user_id'

      response '200', 'Unauthenticated (only public)' do
        let(:Authorization) { nil }

        schema type: :array, items: { type: :object }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.map { |w| w['id'] }).to include(public_wishlist.id)
          expect(body.map { |w| w['id'] }).not_to include(private_wishlist.id)
        end
      end

      response '200', 'Authenticated non-friend (only public)' do
        security [bearer_auth: []]

        schema type: :array, items: { type: :object }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.map { |w| w['id'] }).to include(public_wishlist.id)
          expect(body.map { |w| w['id'] }).not_to include(private_wishlist.id)
        end
      end

      response '200', 'Friend/owner (public + private)' do
        security [bearer_auth: []]

        before do
          create(:friendship, :accepted, requester: owner, addressee: viewer)
        end

        schema type: :array, items: { type: :object }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.map { |w| w['id'] }).to include(public_wishlist.id, private_wishlist.id)
        end
      end
    end
  end

  path '/api/wishlists/{id}' do
    get 'Get a wishlist (enforces visibility)' do
      tags 'Wishlists'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'Wishlist ID'

      response '200', 'Public wishlist (unauthenticated allowed)' do
        let(:Authorization) { nil }
        let(:id) { public_wishlist.id }

        schema type: :object

        run_test!
      end

      response '404', 'Private wishlist (unauthenticated denied)' do
        let(:Authorization) { nil }
        let(:id) { private_wishlist.id }

        run_test!
      end

      response '200', 'Private wishlist (friend allowed)' do
        security [bearer_auth: []]
        let(:id) { private_wishlist.id }

        before do
          create(:friendship, :accepted, requester: owner, addressee: viewer)
        end

        schema type: :object

        run_test!
      end
    end
  end

  path '/api/wishlists/{id}/wishes' do
    get 'Get wishlist wishes (enforces visibility, returns all wishes)' do
      tags 'Wishlists'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'Wishlist ID'

      response '200', 'Public wishlist wishes (unauthenticated allowed)' do
        let(:Authorization) { nil }
        let(:id) { public_wishlist.id }

        before do
          create(:wish, user: owner, wishlist: public_wishlist)
        end

        schema type: :array, items: { type: :object }

        run_test!
      end

      response '404', 'Private wishlist wishes (unauthenticated denied)' do
        let(:Authorization) { nil }
        let(:id) { private_wishlist.id }

        run_test!
      end

      response '200', 'Private wishlist wishes (friend allowed)' do
        security [bearer_auth: []]
        let(:id) { private_wishlist.id }

        before do
          create(:friendship, :accepted, requester: owner, addressee: viewer)
          create(:wish, user: owner, wishlist: private_wishlist)
        end

        schema type: :array, items: { type: :object }

        run_test!
      end
    end
  end
end

