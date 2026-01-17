# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/friendships', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id) }
  let(:Authorization) { "Bearer #{token.token}" }

  path '/api/friendships' do
    post('Send friend request') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :addressee_id, in: :body, schema: {
        type: :object,
        properties: {
          addressee_id: { type: :integer }
        },
        required: ['addressee_id']
      }

      response(201, 'successful') do
        let(:addressee_id) { { addressee_id: other_user.id } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('pending')
          expect(data['requester_id']).to eq(user.id)
          expect(data['addressee_id']).to eq(other_user.id)
        end
      end

      response(409, 'already friends or request exists') do
        before { create(:friendship, :accepted, requester: user, addressee: other_user) }
        let(:addressee_id) { { addressee_id: other_user.id } }

        run_test!
      end

      response(422, 'cannot friend yourself') do
        let(:addressee_id) { { addressee_id: user.id } }

        run_test!
      end
    end

    get('List friends') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response(200, 'successful') do
        before do
          friend = create(:user)
          create(:friendship, :accepted, requester: user, addressee: friend)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.size).to eq(1)
        end
      end
    end
  end

  path '/api/friendships/incoming' do
    get('List incoming friend requests') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response(200, 'successful') do
        before { create(:friendship, :pending, requester: other_user, addressee: user) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.size).to eq(1)
          expect(data.first['status']).to eq('pending')
          expect(data.first['addressee_id']).to eq(user.id)
        end
      end
    end
  end

  path '/api/friendships/outgoing' do
    get('List outgoing friend requests') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response(200, 'successful') do
        before { create(:friendship, :pending, requester: user, addressee: other_user) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.size).to eq(1)
          expect(data.first['status']).to eq('pending')
          expect(data.first['requester_id']).to eq(user.id)
        end
      end
    end
  end

  path '/api/friendships/status/{user_id}' do
    parameter name: 'user_id', in: :path, type: :integer, description: 'user_id'

    get('Check friendship status') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response(200, 'no friendship') do
        let(:user_id) { other_user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('none')
        end
      end

      response(200, 'outgoing pending') do
        before { create(:friendship, :pending, requester: user, addressee: other_user) }
        let(:user_id) { other_user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('outgoing_pending')
        end
      end
    end
  end

  path '/api/friendships/{id}/accept' do
    parameter name: 'id', in: :path, type: :integer, description: 'id'

    put('Accept friend request') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:friendship) { create(:friendship, :pending, requester: other_user, addressee: user) }
        let(:id) { friendship.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('accepted')
        end
      end

      response(403, 'forbidden - not addressee') do
        let(:friendship) { create(:friendship, :pending, requester: user, addressee: other_user) }
        let(:id) { friendship.id }

        run_test!
      end
    end
  end

  path '/api/friendships/{id}/reject' do
    parameter name: 'id', in: :path, type: :integer, description: 'id'

    put('Reject friend request') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:friendship) { create(:friendship, :pending, requester: other_user, addressee: user) }
        let(:id) { friendship.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('rejected')
        end
      end
    end
  end

  path '/api/friendships/{id}/cancel' do
    parameter name: 'id', in: :path, type: :integer, description: 'id'

    delete('Cancel friend request') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:friendship) { create(:friendship, :pending, requester: user, addressee: other_user) }
        let(:id) { friendship.id }

        run_test!
      end

      response(403, 'forbidden - not requester') do
        let(:friendship) { create(:friendship, :pending, requester: other_user, addressee: user) }
        let(:id) { friendship.id }

        run_test!
      end
    end
  end

  path '/api/friendships/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'id'

    delete('Remove friendship') do
      tags 'Friendships'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response(200, 'successful as requester') do
        let(:friendship) { create(:friendship, :accepted, requester: user, addressee: other_user) }
        let(:id) { friendship.id }

        run_test!
      end

      response(200, 'successful as addressee') do
        let(:friendship) { create(:friendship, :accepted, requester: other_user, addressee: user) }
        let(:id) { friendship.id }

        run_test!
      end

      response(422, 'not accepted friendship') do
        let(:friendship) { create(:friendship, :pending, requester: user, addressee: other_user) }
        let(:id) { friendship.id }

        run_test!
      end
    end
  end
end
