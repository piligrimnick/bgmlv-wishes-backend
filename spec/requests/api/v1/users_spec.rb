# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:id) { user.id }

  path '/api/users' do
    get 'List users' do
      tags 'Users'
      produces 'application/json'

      response '200', 'Success' do
        schema type: :array, items: { type: :object }
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
      produces 'application/json'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
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
        schema type: :object
        run_test!
      end

      response '403', 'Forbidden' do
        run_test!
      end

      response '422', 'Unprocessable Entity' do
        run_test!
      end
    end
  end
end
