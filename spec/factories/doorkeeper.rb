FactoryBot.define do
  factory :doorkeeper_access_token, class: 'Doorkeeper::AccessToken' do
    resource_owner_id { create(:user).id }
    expires_in { 2.hours }
    application factory: %i[doorkeeper_application], strategy: :null
    scopes { 'read write' }
  end

  factory :doorkeeper_application, class: 'Doorkeeper::Application' do
    name { 'Test App' }
    redirect_uri { 'https://example.com/callback' }
    uid { SecureRandom.uuid }
    secret { SecureRandom.hex(32) }
  end
end
