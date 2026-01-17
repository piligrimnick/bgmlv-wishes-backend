# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Wishes API', type: :request do
  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'read write').token }
  let(:Authorization) { "Bearer #{token}" }
  let(:wish) { create(:wish, user: user) }
  let(:id) { wish.id }
  let(:wish_params) { { wish: { body: 'New body', url: 'http://example.com' } } }

  path '/api/user_wishes/{user_id}' do
    get 'Get user wishes' do
      tags 'Wishes'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :string, description: 'User ID'
      parameter name: :o, in: :query, type: :string, required: false, description: 'Order'

      response '200', 'Success' do
        schema type: :object,
          properties: {
            data: { type: :array, items: { type: :object } },
            metadata: { type: :object }
          }

        before do
          create(:wish, user: user)
        end

        run_test!
      end
    end
  end

  path '/api/realised_user_wishes/{user_id}' do
    get 'Get realised user wishes' do
      tags 'Wishes'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :user_id, in: :path, type: :string, description: 'User ID'
      parameter name: :o, in: :query, type: :string, required: false, description: 'Order'

      response '200', 'Success' do
        schema type: :object,
          properties: {
            data: { type: :array, items: { type: :object } },
            metadata: { type: :object }
          }

        before do
          create(:wish, user: user, state: :realised)
        end

        run_test!
      end
    end
  end

  path '/api/wishes' do
    get 'List current user wishes' do
      tags 'Wishes'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :o, in: :query, type: :string, required: false, description: 'Order'

      response '200', 'Success' do
        schema type: :array, items: { type: :object }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end

    post 'Create a wish' do
      tags 'Wishes'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :wish_params, in: :body, schema: {
        type: :object,
        properties: {
          wish: {
            type: :object,
            properties: {
              body: { type: :string, description: 'Text description' },
              url: { type: :string, description: 'URL' }
            }
          }
        }
      }

      response '201', 'Success' do
        schema type: :object
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end

  path '/api/wishes/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Wish ID'

    get 'Get a wish' do
      tags 'Wishes'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Success' do
        schema type: :object
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end

    put 'Update a wish' do
      tags 'Wishes'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :wish_params, in: :body, schema: {
        type: :object,
        properties: {
          wish: {
            type: :object,
            properties: {
              body: { type: :string, description: 'Text description' },
              url: { type: :string, description: 'URL' }
            }
          }
        }
      }

      response '200', 'Success' do
        schema type: :object

        before do
          wish # Force creation
        end

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end

    delete 'Delete a wish' do
      tags 'Wishes'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Success' do
        schema type: :object
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end

  path '/api/wishes/{id}/realise' do
    put 'Mark wish as realised' do
      tags 'Wishes'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :integer, description: 'Wish ID'

      response '200', 'Success' do
        schema type: :object
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end

  path '/api/wishes/{id}/book' do
    put 'Book a wish' do
      tags 'Wishes'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :integer, description: 'Wish ID'

      response '200', 'Success' do
        schema type: :object
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end

  path '/api/wishes/{id}/unbook' do
    put 'Unbook a wish' do
      tags 'Wishes'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :integer, description: 'Wish ID'

      response '200', 'Success' do
        schema type: :object
        before { create(:booking, wish: wish, user: user) }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end
end
