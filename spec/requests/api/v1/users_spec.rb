# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id) }
  let(:Authorization) { "Bearer #{token.token}" }
  let(:id) { user.id }

  path '/api/users' do
    get 'List users' do
      tags 'Users'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'Success' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { type: :object }
                 },
                 metadata: { type: :object }
               }

        before { create_list(:user, 3) }

        let(:page) { 1 }
        let(:per_page) { 20 }

        run_test!
      end
    end
  end

  path '/api/users/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'User ID'

    get 'Get a user' do
      tags 'Users'
      produces 'application/json'

      response '200', 'Success' do
        schema type: :object
        run_test!
      end
    end

    put 'Update a user' do
      tags 'Users'
      security [{ bearer_auth: [] }]
      produces 'application/json'
      consumes 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              firstname: { type: :string },
              lastname: { type: :string }
            }
          }
        }
      }

      response '200', 'Success' do
        let(:user_params) { { user: { firstname: 'Updated' } } }
        schema type: :object
        run_test!
      end

      response '403', 'Forbidden' do
        let(:other_user) { create(:user) }
        let(:id) { other_user.id }
        let(:user_params) { { user: { firstname: 'Hacked' } } }
        run_test!
      end
    end
  end
end
