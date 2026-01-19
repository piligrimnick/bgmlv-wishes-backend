class AddIsDefaultToWishlists < ActiveRecord::Migration[8.0]
  def change
    add_column :wishlists, :is_default, :boolean, null: false, default: false
    add_index :wishlists, [:user_id, :is_default]
  end
end
