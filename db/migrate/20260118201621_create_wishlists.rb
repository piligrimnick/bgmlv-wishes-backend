class CreateWishlists < ActiveRecord::Migration[8.0]
  def change
    create_table :wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :visibility, null: false, default: 1
      t.boolean :is_default, null: false, default: false

      t.timestamps
    end

    add_index :wishlists, [:user_id, :is_default]
  end
end
