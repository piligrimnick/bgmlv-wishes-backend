FactoryBot.define do
  factory :doorkeeper_access_token, class: 'Doorkeeper::AccessToken' do
    resource_owner_id { create(:user).id }
    expires_in { 2.hours }
    association :application, factory: :doorkeeper_application
  end

  factory :doorkeeper_application, class: 'Doorkeeper::Application' do
    name { 'Test App' }
    redirect_uri { 'https://example.com/callback' }
    uid { SecureRandom.uuid }
    secret { SecureRandom.hex(32) }
  end
end
