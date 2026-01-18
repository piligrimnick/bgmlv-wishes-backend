class AddWishlistIdToWishes < ActiveRecord::Migration[8.0]
  def change
    # NOTE: Nullable initially. We will backfill data using data_migrate, then
    # harden the constraint to NOT NULL + add FK with ON DELETE CASCADE.
    add_reference :wishes, :wishlist, null: true, index: true
  end
end
