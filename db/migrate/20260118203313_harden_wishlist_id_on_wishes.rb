class HardenWishlistIdOnWishes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :wishes, :wishlist_id, false

    # FK is added after backfill. CASCADE is needed for later wishlist deletion behavior.
    add_foreign_key :wishes, :wishlists, column: :wishlist_id, on_delete: :cascade
  end
end
