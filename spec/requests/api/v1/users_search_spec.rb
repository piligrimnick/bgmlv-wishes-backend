# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/users/search', type: :request do
  let(:user) { create(:user, username: 'current') }
  let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id) }
  let(:Authorization) { "Bearer #{token.token}" }

  path '/api/users/search' do
    get('Search users') do
      tags 'Users'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      parameter name: :q, in: :query, type: :string, required: true, description: 'Search query'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response(200, 'successful') do
        before do
          create(:user, username: 'john_doe', firstname: 'John', lastname: 'Doe')
          create(:user, username: 'jane_smith', firstname: 'Jane', lastname: 'Smith')
        end

        let(:q) { 'john' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.any? { |u| u['username'] == 'john_doe' }).to be true
          expect(data.all? { |u| u.key?('friendship_status') }).to be true
        end
      end

      response(200, 'excludes current user') do
        let(:q) { 'current' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.map { |u| u['id'] }).not_to include(user.id)
        end
      end

      response(200, 'includes friendship status') do
        before do
          other = create(:user, username: 'friend_user')
          create(:friendship, :accepted, requester: user, addressee: other)
        end

        let(:q) { 'friend' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.first['friendship_status']).to eq('outgoing_accepted')
        end
      end
    end
  end
end
