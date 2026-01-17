# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/oauth/token' do
    post 'Authenticate with email and password' do
      tags 'Authentication'
      consumes 'application/x-www-form-urlencoded'
      produces 'application/json'

      parameter name: :email, in: :formData, type: :string, required: true, description: 'User email'
      parameter name: :password, in: :formData, type: :string, required: true, description: 'User password'
      parameter name: :grant_type, in: :formData, type: :string, required: true, description: 'OAuth grant type', enum: ['password']

      response '200', 'Authentication successful' do
        let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:email) { user.email }
        let(:password) { 'password123' }
        let(:grant_type) { 'password' }

        schema type: :object,
               properties: {
                 access_token: { type: :string, description: 'OAuth access token' },
                 token_type: { type: :string, description: 'Token type (Bearer)' },
                 expires_in: { type: :integer, description: 'Token expiration time in seconds' },
                 scope: { type: :string, description: 'Token scope' },
                 created_at: { type: :integer, description: 'Token creation timestamp' },
                 id: { type: :integer, description: 'User ID' },
                 username: { type: :string, nullable: true, description: 'Username' },
                 firstname: { type: :string, nullable: true, description: 'First name' },
                 lastname: { type: :string, nullable: true, description: 'Last name' }
               },
               required: %w[access_token token_type expires_in scope created_at id]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['access_token']).to be_present
          expect(data['token_type']).to eq('Bearer')
          expect(data['id']).to eq(user.id)
          # Ensure email is NOT returned (security)
          expect(data).not_to have_key('email')
        end
      end

      response '400', 'Invalid credentials' do
        let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:email) { user.email }
        let(:password) { 'wrongpassword' }
        let(:grant_type) { 'password' }

        schema type: :object,
               properties: {
                 error: { type: :string, description: 'Error code' },
                 error_description: { type: :string, description: 'Human-readable error description' }
               },
               required: %w[error error_description]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('invalid_grant')
          expect(data['error_description']).to be_present
        end
      end

      response '400', 'Missing parameters' do
        let(:email) { '' }
        let(:password) { '' }
        let(:grant_type) { 'password' }

        schema type: :object,
               properties: {
                 error: { type: :string },
                 error_description: { type: :string }
               }

        run_test!
      end

      response '400', 'User not found' do
        let(:email) { 'nonexistent@example.com' }
        let(:password) { 'password123' }
        let(:grant_type) { 'password' }

        schema type: :object,
               properties: {
                 error: { type: :string },
                 error_description: { type: :string }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('invalid_grant')
        end
      end
    end
  end

  # If you're also supporting Telegram authentication via assertion grant
  path '/oauth/token' do
    post 'Authenticate with Telegram' do
      tags 'Authentication'
      consumes 'application/x-www-form-urlencoded'
      produces 'application/json'

      parameter name: :grant_type, in: :formData, type: :string, required: true, description: 'OAuth grant type', enum: ['assertion']
      parameter name: 'auth_data[id]', in: :formData, type: :string, required: true, description: 'Telegram user ID'
      parameter name: 'auth_data[first_name]', in: :formData, type: :string, required: false, description: 'Telegram first name'
      parameter name: 'auth_data[last_name]', in: :formData, type: :string, required: false, description: 'Telegram last name'
      parameter name: 'auth_data[username]', in: :formData, type: :string, required: false, description: 'Telegram username'
      parameter name: 'auth_data[auth_date]', in: :formData, type: :string, required: true, description: 'Telegram auth date'
      parameter name: 'auth_data[hash]', in: :formData, type: :string, required: true, description: 'Telegram hash'

      response '200', 'Telegram authentication successful' do
        let(:grant_type) { 'assertion' }
        let(:'auth_data[id]') { '123456' }
        let(:'auth_data[first_name]') { 'Test' }
        let(:'auth_data[last_name]') { 'User' }
        let(:'auth_data[username]') { 'testuser' }
        let(:'auth_data[auth_date]') { Time.now.to_i.to_s }
        let(:'auth_data[hash]') { 'valid_hash' }

        let!(:user) { create(:user) }

        before do
          allow(Telegram::Auth).to receive(:call).and_return(user)
        end

        schema type: :object,
               properties: {
                 access_token: { type: :string },
                 token_type: { type: :string },
                 expires_in: { type: :integer },
                 scope: { type: :string },
                 created_at: { type: :integer },
                 id: { type: :integer },
                 username: { type: :string, nullable: true },
                 firstname: { type: :string, nullable: true },
                 lastname: { type: :string, nullable: true }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['access_token']).to be_present
          expect(data['token_type']).to eq('Bearer')
          expect(data['id']).to eq(user.id)
        end
      end
    end
  end
end
