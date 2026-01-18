class WishlistSerializer
  attr_reader :wishlist

  def initialize(wishlist)
    @wishlist = wishlist
  end

  def as_json
    {
      id: wishlist.id,
      user_id: wishlist.user_id,
      name: wishlist.name,
      description: wishlist.description,
      visibility: wishlist.visibility,
      created_at: wishlist.created_at,
      updated_at: wishlist.updated_at
    }
  end

  def self.collection(wishlists)
    wishlists.map { |wishlist| new(wishlist).as_json }
  end
end

