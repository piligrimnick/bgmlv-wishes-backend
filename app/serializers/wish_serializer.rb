class WishSerializer
  attr_reader :wish

  def initialize(wish)
    @wish = wish
  end

  def as_json
    {
      id: wish.id,
      body: wish.body,
      url: wish.url,
      state: wish.state,
      created_at: wish.created_at,
      updated_at: wish.updated_at,
      user_id: wish.user_id,
      user: wish.user ? UserSerializer.new(wish.user).as_json(secure: false) : nil,
      booker_id: wish.booking&.user_id,
      booker: wish.booker ? UserSerializer.new(wish.booker).as_json(secure: false) : nil,
      booking: wish.booking ? BookingSerializer.new(wish.booking).as_json : nil,
      picture_url: picture_url
    }
  end

  def self.collection(wishes)
    wishes.map { |wish| new(wish).as_json }
  end

  private

  def picture_url
    return nil unless wish.picture.attached?

    Rails.application.routes.url_helpers.rails_blob_url(wish.picture, only_path: false)
  end
end
