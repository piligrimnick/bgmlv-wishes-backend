module DoorkeeperSpecHelper
  def bearer_token_for(user)
    token = Doorkeeper::AccessToken.create!(
      resource_owner_id: user.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      scopes: 'read write'
    )
    "Bearer #{token.token}"
  end
end

RSpec.configure do |config|
  config.include DoorkeeperSpecHelper, type: :request
end
